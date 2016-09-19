
<!-- README.md is generated from README.Rmd. Please edit that file -->
``` r
devtools::load_all()
#> Loading queuecomputer
```

``` r
arrival_df <- data.frame(ID = c(1:100), times = rlnorm(100, meanlog = 3))
service <- rlnorm(100)
firstqueue <- queue_step(arrival_df = arrival_df, service = service)
secondqueue <- queue_step(arrival_df = arrival_df,
    Number_of_queues = stepfun(c(15,30,50), c(1,3,1,10)), service = service)

curve(ecdf(arrival_df$times)(x) * 100 , from = 0, to = 200,
    xlab = "time", ylab = "Number of customers")
curve(ecdf(firstqueue$times)(x) * 100 , add = TRUE, col = "red")
curve(ecdf(secondqueue$times)(x) * 100, add = TRUE, col = "blue")
legend(100,40, legend = c("Customer input - arrivals",
    "Customer output - firstqueue",
    "Customer output - secondqueue"),
    col = c("black","red","blue"), lwd = 1, cex = 0.8
)
```

![](README-unnamed-chunk-3-1.png)