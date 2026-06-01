
#install.packages("rlang")
library(readr)
library(R.matlab)



fredqd <- function(file = "C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\current.csv", date_start = NULL, date_end = NULL, transform = TRUE) {
  # Error checking
  if (!is.logical(transform))
    stop("'transform' must be logical.")
  if ((class(date_start) != "Date") && (!is.null(date_start)))
    stop("'date_start' must be Date or NULL.")
  if ((class(date_end) != "Date") && (!is.null(date_end)))
    stop("'date_end' must be Date or NULL.")
  
  if (class(date_start) == "Date") {
    if (as.numeric(format(date_start, "%d")) != 1)
      stop("'date_start' must be Date whose day is 1.")
    if (!as.numeric(format(date_start, "%m")) %in% c(3,6,9,12))
      stop("'date_start' must be Date whose month is March, June,
           September, or December.")
    if (date_start < as.Date("1959-03-01"))
      stop("'date_start' must be later than 1959-03-01.")
  }
  
  if (class(date_end) == "Date") {
    if (as.numeric(format(date_end, "%d")) != 1)
      stop("'date_end' must be Date whose day is 1.")
    if (!as.numeric(format(date_end, "%m")) %in% c(3,6,9,12))
      stop("'date_end' must be Date whose month is March, June,
           September, or December.")
  }
  
  
  
  # Prepare raw data
  rawdata <- readr::read_csv(file="C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\current.csv", col_names = FALSE, col_types = cols(X1 = col_date(format = "%m/%d/%Y")),
                             skip = 3)
  sum(is.na(rawdata)) #count NA values
  #ind_notna <- min(which(is.na(rawdata[,1]))) - 1
  #suppressWarnings(min(which(is.na(rawdata[,1])))-1)
  #rawdata <- rawdata[1:ind_notna, ] # remove NA rows
  rawdata <- na.omit(rawdata)
  rawdata <- as.data.frame(rawdata)
  
  attrdata <- read.csv("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\current.csv", header = FALSE, nrows = 3)
  header <- c("date", unlist(attrdata[1,2:ncol(attrdata)]))
  colnames(rawdata) <- header
  
  
  # Import tcode tcodes is an internal data of the R package
  tcode <- unlist(attrdata[3,2:ncol(attrdata)])
  
  
  # Subfunction transxf: data transformation based on tcodes
  transxf <- function(x, tcode) {
    # Number of observations (including missing values)
    n <- length(x)
    
    # Value close to zero
    small <- 1e-06
    
    # Allocate output variable
    y <- rep(NA, n)
    y1 <- rep(NA, n)
    
    # TRANSFORMATION: Determine case 1-7 by transformation code
    if (tcode == 1) {
      # Case 1 Level (i.e. no transformation): x(t)
      y <- x
      
    } else if (tcode == 2) {
      # Case 2 First difference: x(t)-x(t-1)
      y[2:n] <- x[2:n] - x[1:(n - 1)]
      
    } else if (tcode == 3) {
      # case 3 Second difference: (x(t)-x(t-1))-(x(t-1)-x(t-2))
      y[3:n] <- x[3:n] - 2 * x[2:(n - 1)] + x[1:(n - 2)]
      
    } else if (tcode == 4) {
      # case 4 Natural log: ln(x)
      if (min(x, na.rm = TRUE) > small)
        y <- log(x)
      
    } else if (tcode == 5) {
      # case 5 First difference of natural log: ln(x)-ln(x-1)
      if (min(x, na.rm = TRUE) > small) {
        x <- log(x)
        y[2:n] <- x[2:n] - x[1:(n - 1)]
      }
      
    } else if (tcode == 6) {
      # case 6 Second difference of natural log:
      # (ln(x)-ln(x-1))-(ln(x-1)-ln(x-2))
      if (min(x, na.rm = TRUE) > small) {
        x <- log(x)
        y[3:n] <- x[3:n] - 2 * x[2:(n - 1)] + x[1:(n - 2)]
      }
      
    } else if (tcode == 7) {
      # case 7 First difference of percent change:
      # (x(t)/x(t-1)-1)-(x(t-1)/x(t-2)-1)
      y1[2:n] <- (x[2:n] - x[1:(n - 1)])/x[1:(n - 1)]
      y[3:n] <- y1[3:n] - y1[2:(n - 1)]
    }
    
    return(y)
  }
  
  
  # Transform data
  if (isTRUE(transform)) {
    # Apply transformations
    N <- ncol(rawdata)
    data <- rawdata
    data[, 2:N] <- NA
    
    # Perform transformation using subfunction transxf (see below for
    # details)
    for (i in 2:N) {
      temp <- transxf(rawdata[, i], tcode[i - 1])
      data[, i] <- temp
    }
    
  } else {
    data <- rawdata
  }
  
  
  # Null case of date_start and date_end
  if (is.null(date_start))
    date_start <- as.Date("1959-03-01")
  if (is.null(date_end))
    date_end <- data[, 1][nrow(data)]
  
  
  # Subset data
  index_start <- which.max(data[, 1] == date_start)
  index_end <- which.max(data[, 1] == date_end)
  
  outdata <- data[index_start:index_end, ]
  class(outdata) <- c("data.frame", "fredqd")
  return(outdata)
  
}

data<-fredqd(file="C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\current.csv", date_start = NULL, date_end = NULL, transform = TRUE)
data <- na.omit(data) #no missing values
rownames(data) <- c(1:88)
act_data <- data[1:78, 2:247] #actual data from 2000:4 until 2019:4
act_data=scale(act_data)
act_data <- as.data.frame(act_data)
data2 <- act_data[1:52,] #omit covid period (data to forecast)
rm(data)




#import estimates of chi and xi from MatLab

chi_tot <- readMat("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\chi_tot.mat")
chi_tot <-as.data.frame(chi_tot)
xi_tot <- readMat("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\xi_tot.mat")
xi_tot <-as.data.frame(xi_tot)

chi_rol <- readMat("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\chi_rol.mat")
chi_rol <-as.data.frame(chi_rol)
xi_rol <- readMat("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\xi_rol.mat")
xi_rol <-as.data.frame(xi_rol)
#r=5 q=3


fcast_chi1 <- readMat("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\fcast_chi1.mat")
fcast_chi1 <- as.data.frame(fcast_chi1)

fcast_chi4 <- readMat("C:\\Users\\feder\\Desktop\\Project\\Bertoia_Co (Machine Learning)\\fcast_chi4.mat")
fcast_chi4 <- as.data.frame(fcast_chi4)




colnames(xi_tot) <- colnames(data2)
colnames(chi_tot) <- colnames(data2)
colnames(xi_rol) <- colnames(data2)
colnames(chi_rol) <- colnames(data2)
colnames(fcast_chi1) <- colnames(data2)
colnames(fcast_chi4) <- colnames(data2)

write.csv(act_data, file = "act_data.csv", row.names = FALSE)