cat <<HEREDOC | clickhouse-client -n
DROP TABLE IF EXISTS src_table;
DROP TABLE IF EXISTS dst_table;

CREATE TABLE src_table ( id0 UInt64, logdate DateTime, date Date DEFAULT toDate(logdate), id1 UInt32, id2 UInt32, id4 UInt8, str_id3 String, str_id2 String) ENGINE = MergeTree PARTITION BY date ORDER BY ( id1, id2, id4, logdate) SETTINGS index_granularity = 1024 ;
CREATE TABLE dst_table ( date Date, id1 UInt32, str_id2 String, str_id3_array_state AggregateFunction(groupUniqArray, String)) ENGINE = AggregatingMergeTree PARTITION BY date ORDER BY ( id1, str_id2) SETTINGS index_granularity = 8192 ;
HEREDOC

cat data3.tsv | clickhouse-client --query='INSERT INTO src_table FORMAT TSV'

clickhouse-client --query="insert into dst_table SELECT date, id1, str_id2, groupUniqArrayState(str_id3) AS str_id3_array_state FROM src_table WHERE ((date >= '2019-02-14') AND (date <= '2019-02-14')) AND (id0 <= 1536343204 + 248000) GROUP BY date, id1, str_id2"