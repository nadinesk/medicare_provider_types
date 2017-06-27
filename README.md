# Figuring out What to Do
I wanted to play around a little with the [Medicare data](https://cloud.google.com/bigquery/public-data/medicare) on Google BigQuery (even though I have no background in healthcare policy, and don't know that much about Medicare).

I looked at the `physicians_and_other_supplier_2014` table. This table shows the number of Medicare beneficiares and services per provider during 2014 (along with their address), the medicare allowed amount, charge amount, and payment amount. I looked at what appears to be (?) a pretty straight-forward variable, `bene_unique_cnt`, for the Number of Beneficiaries. Given the variables in this table, I tried to answer this question: For each state, which provider type has the highest count of beneficiaries? And the summary question, how do top provider types differ across the U.S.?

The summary answer is:

{% highlight r %}
> tbl_df(top_prov_type_count)
# A tibble: 6 x 3
                  Var1  Freq  perc
                <fctr> <int> <chr>
1  Clinical Laboratory    30 46.9%
2 Diagnostic Radiology    15 23.4%
3   Emergency Medicine     6  9.4%
4      Family Practice     8 12.5%
5    Internal Medicine     4  6.2%
6   Nurse Practitioner     1  1.6%

{% endhighlight %}

They don't differ much. The top provider type by benficiary count for 46.9% of states is Clinical Laboratory. I don't have a baseline comparison of non-Medicare beneficiaries for each provider type, so I don't know how, or if, it's different.

I used the [`bigrquery`](https://github.com/rstats-db/bigrquery) R library to pull in and analyze the data.


### Notes

Comparing Medicare beneficiary counts, and percentage of state population, by provider type, and any changes from 2012 to 2014.
Top provider type for each state, for each year from 2012 to 2014
Most frequent provider types across the states

https://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?pid=PEP_2016_PEPANNRES&prodType=table
