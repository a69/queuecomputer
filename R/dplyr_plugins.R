
#' Compute queue lengths from arrival, service and departure data
#' @export
#' @importFrom dplyr %>%
#' @param arrivals vector of arrival times
#' @param service vector of service times
#' @param departure vector of departure times
#' @examples
#' library(ggplot2)
#' set.seed(1L)
#' n_customers <- 100
#'
#' queueoutput_df <- data.frame(
#'   arrivals = runif(n_customers, 0, 300),
#'   service = rexp(n_customers)
#' )
#'
#' queueoutput_df <- queueoutput_df %>% mutate(
#'   departures = queue(arrivals, service, servers = 2)
#' )
#'
#' queue_lengths(
#'   queueoutput_df$arrivals,
#'   queueoutput_df$service,
#'   queueoutput_df$departures
#' )
#'
#' # The dplyr way
#' queueoutput_df %>% do(
#'   queue_lengths(.$arrivals, .$service, .$departures))
#'
#' n_customers <- 1000
#'
#' queueoutput_df <- data.frame(
#'   arrivals = runif(n_customers, 0, 300),
#'   service = rexp(n_customers),
#'   route = sample(c("a", "b"), n_customers, TRUE)
#' )
#'
#' server_df <- data.frame(
#'   route = c("a", "b"),
#'   servers = c(2, 3)
#' )
#'
#' output <- queueoutput_df %>%
#'   left_join(server_df) %>%
#'   group_by(route) %>%
#'   mutate(
#'     departures = queue(arrivals, service, servers = servers[1])
#'   ) %>%
#'   do(queue_lengths(.$arrivals, .$service, .$departures))
#'
#'
#' ggplot(output) +
#'   aes(x = time, y = QueueLength) + geom_step() +
#'   facet_grid(~route)
queue_lengths <- function(arrivals, service = 0, departures){

  if(length(service) == 1){
    stopifnot(service == 0)
    check_queueinput(arrivals, service = departures)
  } else {
    check_queueinput(arrivals, service, departures)
  }

  queuedata <- tidyr::gather(
    data.frame(
      input = arrivals,
      output = departures - service + 1e-8
    ),
    factor_key = TRUE
  )

  state_df <- data.frame(
    key = as.factor(c("input", "output")),
    state = c(1, -1)
  )

  queuedata <- suppressMessages(
    dplyr::left_join(queuedata, state_df)
  )

  # queuedata <- queuedata %>% arrange(value, key) %>% mutate(
  #   QueueLength = cumsum(state),
  #   time = value
  # )

  queuedata <- dplyr::mutate(
    dplyr::arrange(queuedata, value, key),
    queuelength = cumsum(state),
    times = value
  )

  queuedata <- dplyr::select(queuedata, times, queuelength)

  return(queuedata)

}

#' Compute time average queue length
#' @param times numeric vector of times
#' @param queuelength numeric vector of queue lengths
#' @examples
#' n <- 1e3
#' arrivals <- cumsum(rexp(n))
#' service <- rexp(n)
#' departures <- queue(arrivals, service, 1)
#'
#' queuedata <- queue_lengths(arrivals, service, departures)
#' average_queue(queuedata$times, queuedata$queuelength)
#' @export
average_queue <- function(times, queuelength){
  times <- c(0, times)
  (diff(times) %*% queuelength) / (times[length(times)] - times[1])
}

#' Summary queue
ql_summary <- function(times, queuelength){
  x <- dplyr::data_frame(
    times = c(0,times), queuelength = c(0,queuelength)
  )

  return(
    x %>%
    dplyr::mutate(diff_times = c(diff(times), 0)) %>%
    dplyr::group_by(queuelength) %>%
    dplyr::summarise(proportion = sum(diff_times)) %>%
    dplyr::mutate(proportion = proportion / sum(proportion))
  )
}


#' Summary details
#'
summary_details <- function(arrivals, service, departures){
  serviced_customers = is.finite(queue_df$times)
  sc <- serviced_customers

  response_time <- departures[sc] - arrivals[sc]
  waiting_time <- departures[sc] - service[sc] - arrivals[sc]

  mean_response_time <- mean(response_time)
  mean_waiting_time <- mean(waiting_time)
}


#' summarise it all
summary_all <- function(arrivals, service, departures){
  queue_lengths(arrivals, service, departures) %>% summary_queue()
}










