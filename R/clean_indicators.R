#' Clean up indicators codes and disaggs for ease of use
#'
#' @description Adopted from OHA-SIEI-SI/tameDP
#'
#' @param df data frame to adjust
#'
#' @export
#' @importFrom magrittr %>%

clean_indicators <- function(df){

  suppressWarnings(
    df <- df %>%
      tidyr::separate(indicatorcode,
                      c("indicator", "numeratordenom", "disaggregate", NA, "otherdisaggregate"),
                      sep = "\\.", remove = FALSE))

  #result status
  df <- df %>%
    dplyr::mutate(resultstatus = dplyr::case_when(
                    otherdisaggregate %in% c("NewPos", "KnownPos", "Positive") ~ "Positive",
                    otherdisaggregate %in% c("NewNeg", "Negative")             ~ "Negative",
                    otherdisaggregate == "Unknown"                             ~ "Unknown"),
                  otherdisaggregate = ifelse(!stringr::str_detect(indicator, "STAT") &
                                               otherdisaggregate %in% c("NewPos", "Positive",
                                                                        "NewNeg", "Negative",
                                                                        "Unknown"),
                                             as.character(NA), otherdisaggregate))
  #convert external modalities
  df <- convert_mods(df)

  #move targets to end
  df <- df %>%
    dplyr::select(-target, dplyr::everything())

  return(df)
}
