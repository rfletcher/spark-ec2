print('Now connecting to Spark for you.') 
 
spark_link <- system('cat /spark/spark-ec2/cluster-url', intern=TRUE)

.libPaths(c(.libPaths(), '/spark/spark/R/lib')) 
Sys.setenv(SPARK_HOME = '/spark/spark') 
Sys.setenv(PATH = paste(Sys.getenv(c('PATH')), '/spark/spark/bin', sep=':')) 
library(SparkR) 

sc <- sparkR.init(spark_link) 
sqlContext <- sparkRSQL.init(sc) 

print('Spark Context available as \"sc\". \\n')
print('Spark SQL Context available as \"sqlContext\". \\n')