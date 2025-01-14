

* [Terms Aggregation | Elasticsearch Reference [5.5] | Elastic ](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-terms-aggregation.html)
* [elasticsearch/terms-aggregation.asciidoc at master · elastic/elasticsearch ](https://github.com/elastic/elasticsearch/blob/master/docs/reference/aggregations/bucket/terms-aggregation.asciidoc)


  Pipeline Aggregations  »
Terms Aggregationedit
A multi-bucket value source based aggregation where buckets are dynamically built - one per unique value.

Example:
```json
{
    "aggs" : {
        "genres" : {
            "terms" : { "field" : "genre" }
        }
    }
}
```
Response:
```json
{
    ...

    "aggregations" : {
        "genres" : {
            "doc_count_error_upper_bound": 0, 
            "sum_other_doc_count": 0, 
            "buckets" : [ 
                {
                    "key" : "jazz",
                    "doc_count" : 10
                },
                {
                    "key" : "rock",
                    "doc_count" : 10
                },
                {
                    "key" : "electronic",
                    "doc_count" : 10
                },
            ]
        }
    }
}
```

an upper bound of the error on the document counts for each term, see below



when there are lots of unique terms, elasticsearch only returns the top terms; this number is the sum of the document counts for all buckets that are not part of the response



the list of the top buckets, the meaning of top being defined by the order

By default, the terms aggregation will return the buckets for the top ten terms ordered by the doc_count. One can change this default behaviour by setting the size parameter.

Sizeedit
The size parameter can be set to define how many term buckets should be returned out of the overall terms list. By default, the node coordinating the search process will request each shard to provide its own top size term buckets and once all shards respond, it will reduce the results to the final list that will then be returned to the client. This means that if the number of unique terms is greater than size, the returned list is slightly off and not accurate (it could be that the term counts are slightly off and it could even be that a term that should have been in the top size buckets was not returned).

Document counts are approximateedit
As described above, the document counts (and the results of any sub aggregations) in the terms aggregation are not always accurate. This is because each shard provides its own view of what the ordered list of terms should be and these are combined to give a final view. Consider the following scenario:

A request is made to obtain the top 5 terms in the field product, ordered by descending document count from an index with 3 shards. In this case each shard is asked to give its top 5 terms.

{
    "aggs" : {
        "products" : {
            "terms" : {
                "field" : "product",
                "size" : 5
            }
        }
    }
}
The terms for each of the three shards are shown below with their respective document counts in brackets:

Shard A	Shard B	Shard C
1

Product A (25)

Product A (30)

Product A (45)

2

Product B (18)

Product B (25)

Product C (44)

3

Product C (6)

Product F (17)

Product Z (36)

4

Product D (3)

Product Z (16)

Product G (30)

5

Product E (2)

Product G (15)

Product E (29)

6

Product F (2)

Product H (14)

Product H (28)

7

Product G (2)

Product I (10)

Product Q (2)

8

Product H (2)

Product Q (6)

Product D (1)

9

Product I (1)

Product J (8)

10

Product J (1)

Product C (4)

The shards will return their top 5 terms so the results from the shards will be:

Shard A	Shard B	Shard C
1

Product A (25)

Product A (30)

Product A (45)

2

Product B (18)

Product B (25)

Product C (44)

3

Product C (6)

Product F (17)

Product Z (36)

4

Product D (3)

Product Z (16)

Product G (30)

5

Product E (2)

Product G (15)

Product E (29)

Taking the top 5 results from each of the shards (as requested) and combining them to make a final top 5 list produces the following:

1

Product A (100)

2

Product Z (52)

3

Product C (50)

4

Product G (45)

5

Product B (43)

Because Product A was returned from all shards we know that its document count value is accurate. Product C was only returned by shards A and C so its document count is shown as 50 but this is not an accurate count. Product C exists on shard B, but its count of 4 was not high enough to put Product C into the top 5 list for that shard. Product Z was also returned only by 2 shards but the third shard does not contain the term. There is no way of knowing, at the point of combining the results to produce the final list of terms, that there is an error in the document count for Product C and not for Product Z. Product H has a document count of 44 across all 3 shards but was not included in the final list of terms because it did not make it into the top five terms on any of the shards.

Shard Sizeedit
The higher the requested size is, the more accurate the results will be, but also, the more expensive it will be to compute the final results (both due to bigger priority queues that are managed on a shard level and due to bigger data transfers between the nodes and the client).

The shard_size parameter can be used to minimize the extra work that comes with bigger requested size. When defined, it will determine how many terms the coordinating node will request from each shard. Once all the shards responded, the coordinating node will then reduce them to a final result which will be based on the size parameter - this way, one can increase the accuracy of the returned terms and avoid the overhead of streaming a big list of buckets back to the client.

Note
shard_size cannot be smaller than size (as it doesn’t make much sense). When it is, elasticsearch will override it and reset it to be equal to size.

The default shard_size will be size if the search request needs to go to a single shard, and (size * 1.5 + 10) otherwise.

Calculating Document Count Erroredit
There are two error values which can be shown on the terms aggregation. The first gives a value for the aggregation as a whole which represents the maximum potential document count for a term which did not make it into the final list of terms. This is calculated as the sum of the document count from the last term returned from each shard .For the example given above the value would be 46 (2 + 15 + 29). This means that in the worst case scenario a term which was not returned could have the 4th highest document count.

{
    ...

    "aggregations" : {
        "products" : {
            "doc_count_error_upper_bound" : 46,
            "buckets" : [
                {
                    "key" : "Product A",
                    "doc_count" : 100
                },
                {
                    "key" : "Product Z",
                    "doc_count" : 52
                },
                ...
            ]
        }
    }
}
Per bucket document count erroredit
Warning
This functionality is experimental and may be changed or removed completely in a future release. Elastic will take a best effort approach to fix any issues, but experimental features are not subject to the support SLA of official GA features.

The second error value can be enabled by setting the show_term_doc_count_error parameter to true. This shows an error value for each term returned by the aggregation which represents the worst case error in the document count and can be useful when deciding on a value for the shard_size parameter. This is calculated by summing the document counts for the last term returned by all shards which did not return the term. In the example above the error in the document count for Product C would be 15 as Shard B was the only shard not to return the term and the document count of the last term it did return was 15. The actual document count of Product C was 54 so the document count was only actually off by 4 even though the worst case was that it would be off by 15. Product A, however has an error of 0 for its document count, since every shard returned it we can be confident that the count returned is accurate.

{
    ...

    "aggregations" : {
        "products" : {
            "doc_count_error_upper_bound" : 46,
            "buckets" : [
                {
                    "key" : "Product A",
                    "doc_count" : 100,
                    "doc_count_error_upper_bound" : 0
                },
                {
                    "key" : "Product Z",
                    "doc_count" : 52,
                    "doc_count_error_upper_bound" : 2
                },
                ...
            ]
        }
    }
}
These errors can only be calculated in this way when the terms are ordered by descending document count. When the aggregation is ordered by the terms values themselves (either ascending or descending) there is no error in the document count since if a shard does not return a particular term which appears in the results from another shard, it must not have that term in its index. When the aggregation is either sorted by a sub aggregation or in order of ascending document count, the error in the document counts cannot be determined and is given a value of -1 to indicate this.

Orderedit
The order of the buckets can be customized by setting the order parameter. By default, the buckets are ordered by their doc_count descending. It is possible to change this behaviour as documented below:

Warning
Sorting by ascending _count or by sub aggregation is discouraged as it increases the error on document counts. It is fine when a single shard is queried, or when the field that is being aggregated was used as a routing key at index time: in these cases results will be accurate since shards have disjoint values. However otherwise, errors are unbounded. One particular case that could still be useful is sorting by min or max aggregation: counts will not be accurate but at least the top buckets will be correctly picked.

Ordering the buckets by their doc _count in an ascending manner:

{
    "aggs" : {
        "genres" : {
            "terms" : {
                "field" : "genre",
                "order" : { "_count" : "asc" }
            }
        }
    }
}
Ordering the buckets alphabetically by their terms in an ascending manner:

{
    "aggs" : {
        "genres" : {
            "terms" : {
                "field" : "genre",
                "order" : { "_term" : "asc" }
            }
        }
    }
}
Ordering the buckets by single value metrics sub-aggregation (identified by the aggregation name):

{
    "aggs" : {
        "genres" : {
            "terms" : {
                "field" : "genre",
                "order" : { "max_play_count" : "desc" }
            },
            "aggs" : {
                "max_play_count" : { "max" : { "field" : "play_count" } }
            }
        }
    }
}
Ordering the buckets by multi value metrics sub-aggregation (identified by the aggregation name):

{
    "aggs" : {
        "genres" : {
            "terms" : {
                "field" : "genre",
                "order" : { "playback_stats.max" : "desc" }
            },
            "aggs" : {
                "playback_stats" : { "stats" : { "field" : "play_count" } }
            }
        }
    }
}
Note
Pipeline aggs cannot be used for sorting
Pipeline aggregations are run during the reduce phase after all other aggregations have already completed. For this reason, they cannot be used for ordering.

It is also possible to order the buckets based on a "deeper" aggregation in the hierarchy. This is supported as long as the aggregations path are of a single-bucket type, where the last aggregation in the path may either be a single-bucket one or a metrics one. If it’s a single-bucket type, the order will be defined by the number of docs in the bucket (i.e. doc_count), in case it’s a metrics one, the same rules as above apply (where the path must indicate the metric name to sort by in case of a multi-value metrics aggregation, and in case of a single-value metrics aggregation the sort will be applied on that value).

The path must be defined in the following form:

AGG_SEPARATOR       =  '>' ;
METRIC_SEPARATOR    =  '.' ;
AGG_NAME            =  <the name of the aggregation> ;
METRIC              =  <the name of the metric (in case of multi-value metrics aggregation)> ;
PATH                =  <AGG_NAME> [ <AGG_SEPARATOR>, <AGG_NAME> ]* [ <METRIC_SEPARATOR>, <METRIC> ] ;
{
    "aggs" : {
        "countries" : {
            "terms" : {
                "field" : "artist.country",
                "order" : { "rock>playback_stats.avg" : "desc" }
            },
            "aggs" : {
                "rock" : {
                    "filter" : { "term" : { "genre" :  "rock" }},
                    "aggs" : {
                        "playback_stats" : { "stats" : { "field" : "play_count" }}
                    }
                }
            }
        }
    }
}
The above will sort the artist’s countries buckets based on the average play count among the rock songs.

Multiple criteria can be used to order the buckets by providing an array of order criteria such as the following:

{
    "aggs" : {
        "countries" : {
            "terms" : {
                "field" : "artist.country",
                "order" : [ { "rock>playback_stats.avg" : "desc" }, { "_count" : "desc" } ]
            },
            "aggs" : {
                "rock" : {
                    "filter" : { "term" : { "genre" : { "rock" }}},
                    "aggs" : {
                        "playback_stats" : { "stats" : { "field" : "play_count" }}
                    }
                }
            }
        }
    }
}
The above will sort the artist’s countries buckets based on the average play count among the rock songs and then by their doc_count in descending order.

Note
In the event that two buckets share the same values for all order criteria the bucket’s term value is used as a tie-breaker in ascending alphabetical order to prevent non-deterministic ordering of buckets.

Minimum document countedit
It is possible to only return terms that match more than a configured number of hits using the min_doc_count option:

{
    "aggs" : {
        "tags" : {
            "terms" : {
                "field" : "tags",
                "min_doc_count": 10
            }
        }
    }
}
The above aggregation would only return tags which have been found in 10 hits or more. Default value is 1.

Terms are collected and ordered on a shard level and merged with the terms collected from other shards in a second step. However, the shard does not have the information about the global document count available. The decision if a term is added to a candidate list depends only on the order computed on the shard using local shard frequencies. The min_doc_count criterion is only applied after merging local terms statistics of all shards. In a way the decision to add the term as a candidate is made without being very certain about if the term will actually reach the required min_doc_count. This might cause many (globally) high frequent terms to be missing in the final result if low frequent terms populated the candidate lists. To avoid this, the shard_size parameter can be increased to allow more candidate terms on the shards. However, this increases memory consumption and network traffic.

shard_min_doc_count parameter

The parameter shard_min_doc_count regulates the certainty a shard has if the term should actually be added to the candidate list or not with respect to the min_doc_count. Terms will only be considered if their local shard frequency within the set is higher than the shard_min_doc_count. If your dictionary contains many low frequent terms and you are not interested in those (for example misspellings), then you can set the shard_min_doc_count parameter to filter out candidate terms on a shard level that will with a reasonable certainty not reach the required min_doc_count even after merging the local counts. shard_min_doc_count is set to 0 per default and has no effect unless you explicitly set it.

Note
Setting min_doc_count=0 will also return buckets for terms that didn’t match any hit. However, some of the returned terms which have a document count of zero might only belong to deleted documents or documents from other types, so there is no warranty that a match_all query would find a positive document count for those terms.

Warning
When NOT sorting on doc_count descending, high values of min_doc_count may return a number of buckets which is less than size because not enough data was gathered from the shards. Missing buckets can be back by increasing shard_size. Setting shard_min_doc_count too high will cause terms to be filtered out on a shard level. This value should be set much lower than min_doc_count/#shards.

Scriptedit
Generating the terms using a script:

{
    "aggs" : {
        "genres" : {
            "terms" : {
                "script" : {
                    "inline": "doc['genre'].value",
                    "lang": "painless"
                }
            }
        }
    }
}
This will interpret the script parameter as an inline script with the default script language and no script parameters. To use a file script use the following syntax:

{
    "aggs" : {
        "genres" : {
            "terms" : {
                "script" : {
                    "file": "my_script",
                    "params": {
                        "field": "genre"
                    }
                }
            }
        }
    }
}
Tip
for indexed scripts replace the file parameter with an id parameter.

Value Scriptedit
{
    "aggs" : {
        "genres" : {
            "terms" : {
                "field" : "gender",
                "script" : {
                    "inline" : "'Genre: ' +_value"
                    "lang" : "painless"
                }
            }
        }
    }
}
Filtering Valuesedit
It is possible to filter the values for which buckets will be created. This can be done using the include and exclude parameters which are based on regular expression strings or arrays of exact values. Additionally, include clauses can filter using partition expressions.

Filtering Values with regular expressionsedit
{
    "aggs" : {
        "tags" : {
            "terms" : {
                "field" : "tags",
                "include" : ".*sport.*",
                "exclude" : "water_.*"
            }
        }
    }
}
In the above example, buckets will be created for all the tags that has the word sport in them, except those starting with water_ (so the tag water_sports will no be aggregated). The include regular expression will determine what values are "allowed" to be aggregated, while the exclude determines the values that should not be aggregated. When both are defined, the exclude has precedence, meaning, the include is evaluated first and only then the exclude.

The syntax is the same as regexp queries.

Filtering Values with exact valuesedit
For matching based on exact values the include and exclude parameters can simply take an array of strings that represent the terms as they are found in the index:

{
    "aggs" : {
        "JapaneseCars" : {
             "terms" : {
                 "field" : "make",
                 "include" : ["mazda", "honda"]
             }
         },
        "ActiveCarManufacturers" : {
             "terms" : {
                 "field" : "make",
                 "exclude" : ["rover", "jensen"]
             }
         }
    }
}
Filtering Values with partitionsedit
Sometimes there are too many unique terms to process in a single request/response pair so it can be useful to break the analysis up into multiple requests. This can be achieved by grouping the field’s values into a number of partitions at query-time and processing only one partition in each request. Consider this request which is looking for accounts that have not logged any access recently:

{
   "size": 0,
   "aggs": {
      "expired_sessions": {
         "terms": {
            "field": "account_id",
            "include": {
               "partition": 0,
               "num_partitions": 20
            },
            "size": 10000,
            "order": {
               "last_access": "asc"
            }
         },
         "aggs": {
            "last_access": {
               "max": {
                  "field": "access_date"
               }
            }
         }
      }
   }
}
This request is finding the last logged access date for a subset of customer accounts because we might want to expire some customer accounts who haven’t been seen for a long while. The num_partitions setting has requested that the unique account_ids are organized evenly into twenty partitions (0 to 19). and the partition setting in this request filters to only consider account_ids falling into partition 0. Subsequent requests should ask for partitions 1 then 2 etc to complete the expired-account analysis.

Note that the size setting for the number of results returned needs to be tuned with the num_partitions. For this particular account-expiration example the process for balancing values for size and num_partitions would be as follows:

Use the cardinality aggregation to estimate the total number of unique account_id values
Pick a value for num_partitions to break the number from 1) up into more manageable chunks
Pick a size value for the number of responses we want from each partition
Run a test request
If we have a circuit-breaker error we are trying to do too much in one request and must increase num_partitions. If the request was successful but the last account ID in the date-sorted test response was still an account we might want to expire then we may be missing accounts of interest and have set our numbers too low. We must either

increase the size parameter to return more results per partition (could be heavy on memory) or
increase the num_partitions to consider less accounts per request (could increase overall processing time as we need to make more requests)
Ultimately this is a balancing act between managing the elasticsearch resources required to process a single request and the volume of requests that the client application must issue to complete a task.

Multi-field terms aggregationedit
The terms aggregation does not support collecting terms from multiple fields in the same document. The reason is that the terms agg doesn’t collect the string term values themselves, but rather uses global ordinals to produce a list of all of the unique values in the field. Global ordinals results in an important performance boost which would not be possible across multiple fields.

There are two approaches that you can use to perform a terms agg across multiple fields:

Script
Use a script to retrieve terms from multiple fields. This disables the global ordinals optimization and will be slower than collecting terms from a single field, but it gives you the flexibility to implement this option at search time.
copy_to field
If you know ahead of time that you want to collect the terms from two or more fields, then use copy_to in your mapping to create a new dedicated field at index time which contains the values from both fields. You can aggregate on this single field, which will benefit from the global ordinals optimization.
Collect modeedit
Deferring calculation of child aggregations

For fields with many unique terms and a small number of required results it can be more efficient to delay the calculation of child aggregations until the top parent-level aggs have been pruned. Ordinarily, all branches of the aggregation tree are expanded in one depth-first pass and only then any pruning occurs. In some scenarios this can be very wasteful and can hit memory constraints. An example problem scenario is querying a movie database for the 10 most popular actors and their 5 most common co-stars:

{
    "aggs" : {
        "actors" : {
             "terms" : {
                 "field" : "actors",
                 "size" : 10
             },
            "aggs" : {
                "costars" : {
                     "terms" : {
                         "field" : "actors",
                         "size" : 5
                     }
                 }
            }
         }
    }
}
Even though the number of actors may be comparatively small and we want only 50 result buckets there is a combinatorial explosion of buckets during calculation - a single actor can produce n² buckets where n is the number of actors. The sane option would be to first determine the 10 most popular actors and only then examine the top co-stars for these 10 actors. This alternative strategy is what we call the breadth_first collection mode as opposed to the depth_first mode.

Note
The breadth_first is the default mode for fields with a cardinality bigger than the requested size or when the cardinality is unknown (numeric fields or scripts for instance). It is possible to override the default heuristic and to provide a collect mode directly in the request:

{
    "aggs" : {
        "actors" : {
             "terms" : {
                 "field" : "actors",
                 "size" : 10,
                 "collect_mode" : "breadth_first" 
             },
            "aggs" : {
                "costars" : {
                     "terms" : {
                         "field" : "actors",
                         "size" : 5
                     }
                 }
            }
         }
    }
}


the possible values are breadth_first and depth_first

When using breadth_first mode the set of documents that fall into the uppermost buckets are cached for subsequent replay so there is a memory overhead in doing this which is linear with the number of matching documents. Note that the order parameter can still be used to refer to data from a child aggregation when using the breadth_first setting - the parent aggregation understands that this child aggregation will need to be called first before any of the other child aggregations.

Warning
Nested aggregations such as top_hits which require access to score information under an aggregation that uses the breadth_first collection mode need to replay the query on the second pass but only for the documents belonging to the top buckets.

Execution hintedit
Warning
The automated execution optimization is experimental, so this parameter is provided temporarily as a way to override the default behaviour
There are different mechanisms by which terms aggregations can be executed:

by using field values directly in order to aggregate data per-bucket (map)
by using ordinals of the field and preemptively allocating one bucket per ordinal value (global_ordinals)
by using ordinals of the field and dynamically allocating one bucket per ordinal value (global_ordinals_hash)
by using per-segment ordinals to compute counts and remap these counts to global counts using global ordinals (global_ordinals_low_cardinality)
Elasticsearch tries to have sensible defaults so this is something that generally doesn’t need to be configured.

map should only be considered when very few documents match a query. Otherwise the ordinals-based execution modes are significantly faster. By default, map is only used when running an aggregation on scripts, since they don’t have ordinals.

global_ordinals_low_cardinality only works for leaf terms aggregations but is usually the fastest execution mode. Memory usage is linear with the number of unique values in the field, so it is only enabled by default on low-cardinality fields.

global_ordinals is the second fastest option, but the fact that it preemptively allocates buckets can be memory-intensive, especially if you have one or more sub aggregations. It is used by default on top-level terms aggregations.

global_ordinals_hash on the contrary to global_ordinals and global_ordinals_low_cardinality allocates buckets dynamically so memory usage is linear to the number of values of the documents that are part of the aggregation scope. It is used by default in inner aggregations.

{
    "aggs" : {
        "tags" : {
             "terms" : {
                 "field" : "tags",
                 "execution_hint": "map" 
             }
         }
    }
}


[experimental] This functionality is experimental and may be changed or removed completely in a future release. Elastic will take a best effort approach to fix any issues, but experimental features are not subject to the support SLA of official GA features. the possible values are map, global_ordinals, global_ordinals_hash and global_ordinals_low_cardinality

Please note that Elasticsearch will ignore this execution hint if it is not applicable and that there is no backward compatibility guarantee on these hints.

Missing valueedit
The missing parameter defines how documents that are missing a value should be treated. By default they will be ignored but it is also possible to treat them as if they had a value.

{
    "aggs" : {
        "tags" : {
             "terms" : {
                 "field" : "tags",
                 "missing": "N/A" 
             }
         }
    }
}


Documents without a value in the tags field will fall into the same bucket as documents that have the value N/A.