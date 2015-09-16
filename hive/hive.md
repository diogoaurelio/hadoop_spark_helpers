# Hive essentials + example - Apache log processing ** WORK IN PROGRESS **
Notes on essentials about hadoop Hive, terminating with example on storing & querying Apache logs dataset with Hive

##Pre-start notes
The logs processed here have the Apache Common Log Format (CLF) following format:
199.72.81.55 - - [01/Jul/1995:00:00:01 -0400] "GET /history/apollo/ HTTP/1.0" 200 6245

More about Apache common access log format [here](http://httpd.apache.org/docs/1.3/logs.html#common)
Dataset Source: [here](http://ita.ee.lbl.gov/html/contrib/NASA-HTTP.html)

# Hive essentials

##Running commands in hive
-----------------------------------------------------
```hql
hive -f myScript.hql
--- OR
hive -e 'SELECT * FROM myTable'
```
- The -f option runs the commands in a specified file (myScript.q in the example)
- The -e option used for short scripts, to specify commands inline (note: final semicolom not required in this case)

##Creating tables in Hive
-----------------------------------------------------
Basic sintax of creating a table inside hdfs:
```hql
CREATE TABLE nameOfTable (column1 TYPE, column2 TYPE, ..)
ROW FORMAT DELIMITTED FIELDS TERMINATED BY '\t' ;
```
This lazily creates a Managed table, meaning only metadata, so should be fast, and will be managed by Hive (will be moved to Hive's data warehouse, and if DROP statement specified, Data will be deleted).
Hive follows strong typing logic, so the types (example: String, Int, Tinyint, Smallint, Bigint, Float, Double, Boolean, Timestamp, Binary, Array, Map, Struct, ..) need to be specified for each column.

The ROW FORMAT clause specifies how each row is terminated - in the example tab delimitted; other usual examples: by the new line character, semicolumn, comma.
Hive (like Pig) has its own version of SERDEs (Serializer and Deserializer), for processing custom file formats. In particular, Hive provides RegexSerDe to process data with predefined REGEX expressions. Example usage:
```hql
CREATE TABLE nameOfTable (column1 TYPE, column2 TYPE, ..)
RAW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerde'
WITH SERDEPROPERTIES(
  "input.regex"= "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)"
  "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s"
)
```

###External tables
-----------------------------------------------------
Two basic types of tables: Managed and External tables.
If DROP statement for Managed tables, then data + metadata will be deleted. With External tables, Hive knows it should not manage data, and will not move it to its datawarehouse directory. So Drop statement in this case only deletes metadata about the table.
```hql
CREATE EXTERNAL TABLE nameOfTable (column1 TYPE, column2 TYPE, ..)
ROW FORMAT DELIMITTED FIELDS TERMINATED BY '\t' ;
```

##Loading data into Hive
-----------------------------------------------------
```hql
LOAD DATA LOCAL INPATH 'local/data/path/sample.txt'
OVERWRITE INTO TABLE nameOfTable;
```
If LOCAL not specified, Hive will search for file in 'hdfs://path'. In this case, with Local specified, it will search local file system.
Hive does not support updates (or deletes); instead use INSERT or OVERWRITE. The OVERWRITE key word tells Hive to delete any existing files in the directory for the table. If INSERT, new data will be added (unless new files have same name as old files - in this case will be overwritten).


##Improving performance and Options - Partion Tables, Buckets, indexing
-----------------------------------------------------

###Partions
-----------------------------------------------------
Partions are way of dividing Tables into more granular structure to improve query performance on slices of data.
Example - dividing records by date - year  - i.e. , records with same year will be grouped and store in the same partition, so that a specific query only needs to load data into that partition.
It is also possible to have multiple subpartitions - year and month for example.
Note: this does not limit ability to query the entire dataset - it only improves if querying for the specific partion, say querying for all records in a specific year and month;
Partitions are defined in table creation stage:
```hql
CREATE TABLE apache_logs ( host STRING, date STRING, time STRING )
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITTED FIELDS TERMINATED BY '\t' ;
LOAD DATA LOCAL INPATH '/path/to/logs'
INTO TABLE apache_logs
PARTITION (dt='01/Jul/1995');
```
###Buckets
-----------------------------------------------------
TODO

###Indexing
-----------------------------------------------------
TODO
```hql
CREATE INDEX idx_month ON TABLE indexedlog(log_month)
AS 'COMPACT'
WITH DEFERRED REBUILD;
```

###More Options
-----------------------------------------------------
Finally if using hadoop HortonWorks distribution (for example in Microsoft Azure Cloud), Tez engine will speed up query performance. Add this line in the beginning of Hive query:
```hql
set hive.execution.engine=tez;
```

##Example Create table & load data into Hive
-----------------------------------------------------
Note: this script is available in scripts/hive_01.hql
