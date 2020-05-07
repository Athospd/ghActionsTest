library(magrittr)
library(stringr)
library(xml2)
library(glue)
library(httr)
channel="#geral"
incoming_webhook_url= Sys.getenv("INCOMING_WEBHOOK_URL")

hour <- RETRY("GET", "https://time.is/", write_disk("hour.html", overwrite = TRUE))

hour_content <- content(hour)
watched_content <- hour_content %>%
  xml_find_first('//*[@id="clock"]') %>%
  xml_text() %>%
  str_extract(":([0-9]{2}):")
cat(getwd())
current_content <- readRDS("current_content.rds")
if(current_content != watched_content) {
  msg <- glue("The content has changed from {current_content} to  {watched_content}. Checked at {Sys.time()}")
  current_content <- watched_content
  saveRDS(current_content, "current_content.rds")

  POST(incoming_webhook_url, body = list(text = msg), encode = "json")
}
