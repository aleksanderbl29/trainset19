install_github("riffomonas/phylotypr")
library(phylotypr)

## code to prepare `trainset19_rdp` and `trainset19_pds` dataset goes here.

## Downloading
download_trainset <- function(type, version, directory = temp_dir) {

  base_url <- "https://mothur.s3.us-east-2.amazonaws.com/wiki/"

  if (version == "19") {
    version_url <- paste0(base_url, "trainset19_072023")
  } else if (version == "18") {
    version_url <- paste0(base_url, "trainset18_062020")
  } else if (version == "16") {
    version_url <- paste0(base_url, "trainset16_022016")
  } else if (version == "14") {
    version_url <- paste0(base_url, "trainset14_032015")
  } else if (version == "10") {
    version_url <- "https://mothur.org/w/images/b/b5/Trainset10_082014"
  } else if (version == "9") {
    version_url <- paste0(base_url, "trainset9_032012")
  } else if (version == "7") {
    version_url <- paste0(base_url, "trainset7_112011")
  } else if (version == "6") {
    version_url <- paste0(base_url, "rdptrainingset")
  } else {
    cli::cli_abort("The provided version is not recognised")
  }

  if (exists("version_url")) {
    cli::cli_alert_info(
      "Attempting to download {substr(basename(version_url), 1, 10)}"
    )} else {
    # stop("The provided version does not exists on the mothur-wiki")
    cli::cli_abort("The provided version is not recognised")
  }

  if (version %in% c("19", "18", "16", "14", "10")) {
    cmp_type <- ".tgz"
  } else if (version %in% c("9", "7", "6")) {
    cmp_type <- ".zip"
  }

  url <- paste0(version_url, ".", type, cmp_type)

  temp_file_name <- paste0(directory, "/", basename(url))

  download.file(url, temp_file_name)

  cli::cli_alert_success("Successfully downloaded the data")

  untar(temp_file_name, exdir = directory)
}


## Joining
join_trainset <- function(type, directory = temp_dir) {

  fasta <- list.files(directory, recursive = TRUE, full.names = TRUE,
                      pattern = glue::glue("{type}.fasta"))
  taxonomy <- list.files(directory, recursive = TRUE, full.names = TRUE,
                         pattern = glue::glue("{type}.tax"))

  fasta_df <- read_fasta(fasta)
  genera <- read_taxonomy(taxonomy)

  df <- dplyr::inner_join(fasta_df, genera, by = "id")
  df <- df[, c("id", "sequence", "taxonomy")]

  return(df)
}

## Creating
create_data <- function(type, trainset_version = "19") {

  temp_dir <- tempdir()

  download_trainset(type = type,
                    version = trainset_version,
                    directory = temp_dir)

  final_dataset <- join_trainset(type = type,
                                 directory = temp_dir)

  return(final_dataset)
}

## Executing
trainset19_rdp <- create_data(type = "rdp", version = "19")
usethis::use_data(trainset19_rdp, compress = "xz", overwrite = TRUE)

trainset19_pds <- create_data(type = "pds", version = "19")
usethis::use_data(trainset19_pds, compress = "xz", overwrite = TRUE)
