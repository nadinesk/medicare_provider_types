library(bigrquery)
library(dplyr)
library(ggplot2)
library(reshape2)
library(scales)


provider_benef_2014 <- " 
SELECT 
  nppes_provider_state, 
  provider_type,
  sum(bene_unique_cnt) as beneficiary_count  
FROM [bigquery-public-data:medicare.physicians_and_other_supplier_2014] 
GROUP BY nppes_provider_state, provider_type
ORDER BY 1,3 DESC
"

provider_benef_2013 <- " 
SELECT 
  nppes_provider_state, 
  provider_type,
  sum(bene_unique_cnt) as beneficiary_count  
FROM [bigquery-public-data:medicare.physicians_and_other_supplier_2013] 
GROUP BY nppes_provider_state, provider_type
ORDER BY 1,3 DESC
"


provider_benef_2012 <- " 
SELECT 
nppes_provider_state, 
provider_type,
sum(bene_unique_cnt) as beneficiary_count  
FROM [bigquery-public-data:medicare.physicians_and_other_supplier_2012] 
GROUP BY nppes_provider_state, provider_type
ORDER BY 1,3 DESC
"


p1 <- query_exec(provider_benef_2014, project = PROJECT_ID)

tbl_df(p1)

p2013 <- query_exec(provider_benef_2013, project = PROJECT_ID)
p2012 <- query_exec(provider_benef_2012, project = PROJECT_ID)


# Top Beneficiary Count by Provider Type per State

as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}

p2 <- p1 %>%
  left_join(abbrev_state) %>%
  rename(GEO.display.label=US.State.) %>%
  left_join(pop_state) %>%
  mutate(prov_state = paste(nppes_provider_state, provider_type, sep="-")) %>%
  group_by(nppes_provider_state) %>%
  top_n(n=1, beneficiary_count) %>%
  mutate_if(is.factor,as.numeric.factor) %>%
  mutate(pop_perc = beneficiary_count/respop72015) 

str(p2)


print(tbl_df(p2), n=61)
str(p2)

top_prov_type_count  <- as.data.frame(table(p2$provider_type)) 

top_prov_type_count$perc <- top_prov_type_count$Freq/(sum(top_prov_type_count$Freq))

tbl_df(top_prov_type_count)
                          


### 2013 data ##

p2013_2 <- p2013 %>%
  left_join(abbrev_state) %>%
  rename(GEO.display.label=US.State.) %>%
  left_join(pop_state) %>%
  mutate(prov_state = paste(nppes_provider_state, provider_type, sep="-")) %>%
  group_by(nppes_provider_state) %>%
  top_n(n=1, beneficiary_count) %>%
  mutate_if(is.factor,as.numeric.factor) %>%
  mutate(pop_perc = beneficiary_count/respop72014) 



top_prov_type_count_2013  <- as.data.frame(table(p2013_2$provider_type)) 

top_prov_type_count_2013$perc <- top_prov_type_count_2013$Freq/(sum(top_prov_type_count_2013$Freq))

tbl_df(top_prov_type_count_2013)



##2012 data###

p2012_2 <- p2012 %>%
  left_join(abbrev_state) %>%
  rename(GEO.display.label=US.State.) %>%
  left_join(pop_state) %>%
  mutate(prov_state = paste(nppes_provider_state, provider_type, sep="-")) %>%
  group_by(nppes_provider_state) %>%
  top_n(n=1, beneficiary_count) %>%
  mutate_if(is.factor,as.numeric.factor) %>%
  mutate(pop_perc = beneficiary_count/respop72013) 



top_prov_type_count_2012  <- as.data.frame(table(p2012_2$provider_type)) 

top_prov_type_count_2012$perc <- top_prov_type_count_2012$Freq/(sum(top_prov_type_count_2012$Freq))

tbl_df(top_prov_type_count_2012)




pop_state <- read.csv("C:/Users/nfischoff/Downloads/PEP_2016_PEPANNRES_with_ann.csv")
abbrev_state <- read.csv("C:/Users/nfischoff/Downloads/st_abbrev.csv")

str(abbrev_state)
names(abbrev_state)[2] <- "nppes_provider_state"
abbrev_state$nppes_provider_state <- as.character(abbrev_state$nppes_provider_state)
str(pop_state)

names(pop_state)[3] <- "nppes_provider_state"

summary_2012to2014 <- top_prov_type_count %>%
                        left_join(top_prov_type_count_2013, by="Var1") %>%
                        left_join(top_prov_type_count_2012, by="Var1")

tbl_df(summary_2012to2014)
str(p2)
state_2012to2014 <- p2 %>%
                      left_join(p2013_2, by="nppes_provider_state") %>%
                      left_join(p2012_2, by="nppes_provider_state")

str(state_2012to2014)



state_2012to2014_1 <- state_2012to2014[c(1,4,2,3,12:14,17,18,19,32,33,34,35,48,49)]
names(state_2012to2014_1)

names(state_2012to2014_1)[1] <- "state_abbrev"
names(state_2012to2014_1)[2] <- "state_name"
names(state_2012to2014_1)[3] <- "2014_provider_type"
names(state_2012to2014_1)[4] <- "2014_beneficiary_count"
names(state_2012to2014_1)[5] <- "7_2013_state_pop"
names(state_2012to2014_1)[6] <- "7_2014_state_pop"
names(state_2012to2014_1)[7] <- "7_2015_state_pop"
names(state_2012to2014_1)[8] <- "2014_perc_pop"
names(state_2012to2014_1)[9] <- "2013_provider_type"
names(state_2012to2014_1)[10] <- "2013_beneficiary_count"
names(state_2012to2014_1)[12] <- "2013_perc_pop"
names(state_2012to2014_1)[13] <- "2012_provider_type"
names(state_2012to2014_1)[14] <- "2012_beneficiary_count"
names(state_2012to2014_1)[16] <- "2012_perc_pop"



state_2012to2014_1$diffxy <- ifelse(state_2012to2014_1$provider_type.x != state_2012to2014_1$provider_type.y, "diff", "")
state_2012to2014_1$diffx_none <- ifelse(state_2012to2014_1$provider_type.x != state_2012to2014_1$provider_type, "diff", "")
state_2012to2014_1$diffy_none <- ifelse(state_2012to2014_1$provider_type.y != state_2012to2014_1$provider_type, "diff", "")
                        

state_2012to2014_2 <- state_2012to2014_1[c(1,2,5,6,7,3,4,8,9,10,12,13,14,16)]

tbl_df(state_2012to2014_2)

# .y => 2013
# .x => 2014 
# none => 2012
names(state_2012to2014_2)

state_2012to2014_format <- state_2012to2014_2 %>%
  filter(!is.na(`7_2013_state_pop`))

state_2012to2014_format
state_2012to2014_3

state_2012to2014_3 <- state_2012to2014_2 %>%
                        filter(!is.na(`7_2013_state_pop`))  %>%
                        mutate(`2014_perc_pop` = percent(`2014_perc_pop`)) %>%
                        mutate(`2013_perc_pop` = percent(`2013_perc_pop`)) %>%
                        mutate(`2012_perc_pop` = percent(`2012_perc_pop`)) 

summary_2012to2014

names(summary_2012to2014)[1] <- "provider_type"
names(summary_2012to2014)[2] <- "2014_count"
names(summary_2012to2014)[3] <- "2014_perc"
names(summary_2012to2014)[4] <- "2013_count"
names(summary_2012to2014)[5] <- "2013_perc"
names(summary_2012to2014)[6] <- "2012_count"
names(summary_2012to2014)[7] <- "2012_perc"



summary_2012to2014_2 <- summary_2012to2014[c(1,3,5,7)]



summary_2012to2014_3 <- melt(summary_2012to2014_2, id=c("provider_type"))



tbl_df(summary_2012to2014_1)

str(summary_2012to2014_1)

snp <- ggplot(summary_2012to2014_3, aes(variable, value)) +   
  geom_bar(aes(fill = provider_type), position = "dodge", stat="identity")
snp



