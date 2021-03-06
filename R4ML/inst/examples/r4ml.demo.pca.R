#
# (C) Copyright IBM Corp. 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#load the r4ml 
library(R4ML)
r4ml.session()

# we would like to limit the dataset to a size so that we can run test faster
#df_max_size <- 1000
df_max_size <- 100000

# set the data to be used for pca
D_names <- c("ActualElapsedTime", "DayofMonth", "DayOfWeek",
                "DepDelay", "Distance", "ArrDelay"
               )

# use the following for the custom dataset
# path <- "/user/data-scientist/airline/1987.csv"
# path <- "/user/data-scientist/airline/*.csv"
# df <- R4ML:::r4ml.read.csv(path, inferSchema=TRUE, header=TRUE)

# this example use the airline dataset shipped with R4ML
df <- as.r4ml.frame(airline)

# limit the number of rows so that we can control the size
df <- limit(df, df_max_size)
ignore <- cache(df) # very important step otherwise the partition gets screw up

# convert to the r4ml frame
df <- SparkR::select(df, D_names)
ignore <- cache(df)
hf = as.r4ml.frame(df)

# do the preprocess of the data set
phf_info <- r4ml.ml.preprocess(
  hf
  ,transformPath = "/tmp"
  ,recodeAttrs=D_names
  ,dummycodeAttrs = c("DayOfWeek")
  ,binningAttrs = c(), numBins=4
  ,omit.na = D_names
)

# dataset after transform
phf <- phf_info$data

# metadata for the transform
pmdb <- phf_info$metadata

# r4ml matrix as the input
hm <- as.r4ml.matrix(phf)
ignore <- cache(hm)

pca_m <- r4ml.pca(hm, center=T, scale=T, projData=T, k = 2)

# look at the dataset after the transform
pca_m

# exit R/R4ML
r4ml.session.stop()
quit("no")

