library("RCurl")
library("XML")
library("stringr")
library("dplyr")
library("downloader")

nameUrl <- "http://www.nanrenvip8.net/find.html"
download.file(url = nameUrl,destfile = "G:/R语言/myWorkSpace/AVinfomation/list.html")
namePage <- htmlParse(file = "G:/R语言/myWorkSpace/AVinfomation/list.html")
names <- xpathSApply(namePage,
                     str_c('//*[@id="all"]/div[',1:500,']/lable'),
                     xmlValue)
orders <- xpathSApply(namePage,
                      str_c('//*[@id="all"]/div[',1:500,']/div/span[1]'),
                      xmlValue)
orders <- str_extract(orders,"[0-9]{1,3}")
photosUrl <- xpathSApply(namePage,
                         str_c('//*[@id="all"]/div[',1:500,']/a/img'),
                         xmlGetAttr,
                         "data-original")
photos <- getBinaryURL(url = photosUrl)
for (i in 130:length(photosUrl)) {
  if(photosUrl[i] != "http://pic.onemai.com"){
    download(photosUrl[i],str_c("G:/R语言/myWorkSpace/AVinfomation/",names[i],".jpg"), mode = "wb")
    print(str_c("第",i,"位女优的照片下载完毕"))
  }
}
listUrl <- xpathSApply(namePage,
                       str_c('//*[@id="all"]/div[',1:500,']/a'),
                       xmlGetAttr,
                       "href")
listUrl <- str_c("http://www.nanrenvip8.net",listUrl)


avImageUrl <- NULL
avFanhao <- NULL
s <- 0
rm(i)
rm(b)
for (c in 1:500) {
  listhtml <- download.file(url = listUrl[c],destfile = str_c("G:/R语言/myWorkSpace/AVinfomation/listhtml/",names[c],".html"))
  
}
x <- 0
for (i in 1:500) {
  dir.create(path = str_c("G:/R语言/myWorkSpace/AVinfomation/",names[i]))
  #listPage <- htmlParse(getURL(url = listUrl[i],encoding = "utf-8"))
  listPage <- htmlParse(file = str_c("G:/R语言/myWorkSpace/AVinfomation/listhtml/",names[i],".html"))
  print(str_c("第",i,"位女优作品列表页面下载并解析完毕。"))
  a <- 1
  avFanhao <- NULL
  avImageUrl <- NULL

  
  repeat{
    newFanhao <- xpathSApply(listPage,
                             str_c('//*[@id="content"]/li[',a,']/div/span[2]/em/b/a'),
                             xmlValue);

    avFanhao <- c(avFanhao,newFanhao);
    avImageUrl <- c(avImageUrl,
                    xpathSApply(listPage,
                                str_c('//*[@id="content"]/li[',a,']/div/span[1]/a/img'),
                                xmlGetAttr,
                                "data-original"));
    a <- a+1;
    if(is.null(newFanhao))
      break;
  }
  x <- length(avFanhao) + x
  assign(str_c("fanhao",i),avFanhao)
  for (b in 1:length(avFanhao)) {#length(avFanhao)
    ##-------------------------下载女优作品封面图片------------------
    if(url.exists(avImageUrl[b])){
    download(avImageUrl[b],str_c("G:/R语言/myWorkSpace/AVinfomation/",names[i],"/",avFanhao[b],".jpg"), mode = "wb")
    print(str_c("第",i,"/500 位女优 ",names[i]," 的第 ",b,"/",length(avFanhao)," 个作品 ",avFanhao[b]," 封面图片下载完毕。"))
    }else{
      s <- s+1
      print(str_c("第",i,"/500 位女优 ",names[i]," 的第 ",b,"/",length(avFanhao)," 个作品 ",avFanhao[b]," 封面图片下载失败。\n当前循环共失败",s,"次"))
    }
    
    ##----------------------------磁力链爬取方案A--------------------
    btPage <- htmlParse(getURL(url = str_c("http://www.btanv.com/search/",avFanhao[b],"-hot-desc-1")))
    ciliUrl <- xpathSApply(btPage,
                           str_c('//*[@id="wall"]/div[',1:5,']/div[3]/a[1]'),
                           xmlGetAttr,
                           "href")
    big <- xpathSApply(btPage,
                       str_c('//*[@id="wall"]/div[',1:5,']/div[2]/p/span[3]'),
                       xmlValue)
    ciliInfo <- data.frame(ciliUrl,big)
    ##---------------------------------------------------------------
    
    ##----------------------------磁力链爬取方案B--------------------
    #cat("\n正在解析初始搜索页面……")
    #originalBtListUrl <- htmlParse(getURL(url = str_c("http://www.btdidi.com/search/",avFanhao[b],".html")))
    #btListUrl <- xpathSApply(originalBtListUrl,'//h2/a',xmlGetAttr,"href")
    #btListUrl<- str_replace(btListUrl,".html",'')
    #btListUrl <- str_c("http://www.btdidi.com",btListUrl,"/1-3.html")
    #cat("\n正在解析资源列表页面……")
    #btListPage <- htmlParse(getURL(url = btListUrl))
    #btPageUrl <- xpathSApply(btListPage,str_c('//*[@id="wall"]/div[',2:6,']/div[1]/h3/a'),xmlGetAttr,"href")
    #btPageUrl <- str_c("http://www.btdidi.com",btPageUrl)
    #cat("\n正在解析资源详情页面……")
    #btPage <- htmlParse(getURL(url = btPageUrl))
    #ciliUrl <- xpathSApply(btPage,'//*[@id="wall"]/div[1]/div[1]/div[2]/a',xmlGetAttr,"href")
    ##----------------------------------------------------------------
    write.table(ciliUrl,
                file = str_c("G:/R语言/myWorkSpace/AVinfomation/",names[i],"/",
                             avFanhao[b],".txt"),
                sep = "\n\n",
                quote = FALSE,row.names = FALSE, col.names = FALSE)
    print(str_c("第",i,"/500 位女优 ",names[i]," 的第 ",b,"/",length(avFanhao)," 个作品 ",avFanhao[b]," 磁力链下载完毕。"))
  }
}
##500位女优
##16837件作品