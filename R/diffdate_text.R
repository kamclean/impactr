# diffdate_text--------------------------------
# Documentation
#' Provide a text version of the difference between 2 dates.
#' @description Used to generate a text version of the difference between 2 dates.
#' @param df Dataframe.
#' @param date_start String of column name in df which represents the start date
#' @param date_end String of column name in df which represents the end date.
#' @return Vector of date range as text.
#' @import magrittr
#' @importFrom dplyr filter mutate arrange select pull
#' @importFrom lubridate ymd month day year
#' @importFrom scales ordinal
#' @export

# Function:
diffdate_text <- function(df, date_start, date_end){
  out <- df %>%
    dplyr::mutate(date_start = dplyr::pull(df, date_start),
                  date_end = dplyr::pull(df, date_end)) %>%
    dplyr::select(date_start, date_end) %>%
    dplyr::mutate(day_start = as.numeric(lubridate::day(lubridate::ymd(date_start))),
                  day_end = as.numeric(lubridate::day(lubridate::ymd(date_end))),
                  month_start = as.character(lubridate::month(lubridate::ymd(date_start), label = TRUE, abbr = FALSE)),
                  month_end = as.character(lubridate::month(lubridate::ymd(date_end), label = TRUE, abbr = FALSE)),
                  year_start = lubridate::year(lubridate::ymd(date_start)),
                  year_end = lubridate::year(lubridate::ymd(date_end))) %>%
    dplyr::mutate(year = ifelse(year_start == year_end, year_start, NA),
                  month = ifelse(month_start == month_end, month_start, NA)) %>%
    dplyr::mutate(range_d = ifelse(day_start==day_end&is.na(month)==F,
                                   scales::ordinal(day_start),
                                   ifelse(day_start<day_end&is.na(month)==F,
                                          paste0(scales::ordinal(day_start), " to ", scales::ordinal(day_end)), NA))) %>%
    dplyr::mutate(range_dm1 = ifelse(is.na(month)==T,
                                     paste0(scales::ordinal(day_start), " ", month_start), NA),
                  range_dm2 = ifelse(is.na(month)==T,
                                     paste0(scales::ordinal(day_end), " ", month_end), NA)) %>%
    dplyr:: mutate(range_dm = ifelse(is.na(range_dm1)==F,
                                     paste0(range_dm1, " to ", range_dm2),
                                     ifelse(is.na(range_dm1)==T&is.na(range_d)==F,
                                            paste0(range_d, " ", month), NA))) %>%
    dplyr::mutate(range_dmy1 = ifelse(is.na(month)==T&is.na(year)==T,
                                      paste0(scales::ordinal(day_start), " ", month_start, " ", year_start), NA),
                  range_dmy2 = ifelse(is.na(month)==T&is.na(year)==T,
                                      paste0(scales::ordinal(day_end), " ", month_end, " ", year_end), NA)) %>%

    dplyr::mutate(range_dmy = ifelse(is.na(range_dmy1)==F,
                                     paste0(range_dmy1, " to ", range_dmy2), NA)) %>%
    dplyr::mutate(date_range = ifelse(is.na(range_dmy)==F,
                                      range_dmy,
                                      ifelse(is.na(range_dmy)==T&is.na(range_dm)==F,
                                             paste(range_dm, year), NA))) %>%
    dplyr::select(date_start, date_end, date_range)

  return(out)}
