
DROP TABLE IF EXISTS apache_logs;

CREATE TABLE apache_logs (
  host STRING,
  identity STRING,
  user STRING,
  date STRING,
  time STRING,
  request STRING,
  status STRING,
  size STRING
)
PARTITIONED BY (dt STRING)
RAW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerde'
WITH SERDEPROPERTIES(
  -- TODO: change regex for seperating date & time
  "input.regex"= "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)"
  "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s"
)

STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH "LOCATION/PATH"
INTO TABLE apache_logs
PARTITION (dt='01/Jul/1995');
