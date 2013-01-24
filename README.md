
# CocoaCKIPClient 中研院斷詞系統Mac客戶端程式

自然語言處理系統最基本需要讓電腦能夠分辨文本中字詞的意義，才能夠更進一步發展出自然語言處理系統的相關演算法，其中斷詞處理便是一個重要的前置技術，而中研院的[斷詞系統](http://ckipsvr.iis.sinica.edu.tw/)便是一個處理中文斷詞的系統。

## 注意事項

### [申請帳號](http://ckipsvr.iis.sinica.edu.tw/)

請使用「[線上服務申請](http://ckipsvr.iis.sinica.edu.tw/webservice.htm)」進行申請帳號的作業，根據經驗申請作業需要幾個工作天，只能耐心等待了。

### 中研院斷詞系統每天上午六點進行系統維護

請注意中研院斷詞系統每天上午六點進行系統維護，每次維護期間大概半小時，這段時間請不要執行程式或是進行重要的排程工作，否則可能會得到非預期的結果。

### 不要一次送出大量資料，也不要密集送出資料

由於斷詞系統是以句為單位處理，因此輸入文章請避免過長的句子造成系統處理上不必要的負擔(合理的句子極少超過80字)：文章如果沒有"?？!！，；。,."等幫助系統辨識句子的標點符號，則請在應該斷句的地方換行。

文章請盡量輸入真正需要斷詞的句子，尤其當來源是非正式的文體如論壇、聊天紀錄等，最好事先進行過濾也利於節省您分析的時間。

## INSTALL

用[CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket)進行Socket的連結。
要從CocoaAsyncSocket專案中，把下面兩個檔案加入你的Xcode專案中：
- GCDAsyncSocket.h
- GCDAsyncSocket.m

接著要把CKIP的主要檔案加入你的專案
- CKIP.h
- CKIP.m

## 使用方法

<pre>
[CKIP *ckip = [CKIP alloc] initWithUsername:@"username" password:@"password"];
[ckip setDelegate:self];
[ckip setRawText:@"這行是要被斷詞的資料"];
[ckip performCKIP];
</pre>

資料回傳後，可以用 `ckipDidReceiveEroorProcessStatus:(NSInteger)code` 先檢查回傳資料是否有問題。
- code=1 表示伺服器內部發生錯誤，可能是由不預期的字元或是過於複雜的句子結構所造成；
- code=2 表示接收到的XML格式有錯誤；
- code=3 表示帳號或密碼錯誤。

資料的回傳用的是delegate方法 `ckipDidFinish:`

只輸出分詞：
<pre>
NSMutableArray *terms = [NSMutableArray new];
for (NSDictionary *t in [ckip terms]) {
    [terms addObject:[NSString stringWithFormat:@"%@\t%@", [t objectForKey:@"term"], [t objectForKey:@"tag"]]];
}
[textView setString:[terms componentsJoinedByString:@"\n"]];
</pre>

輸出分詞後的句子：
<pre>
[textView setString:[[ckip sentences] componentsJoinedByString:@"\n"]];
</pre>

其餘的細節請看範例程式。

## License

Released under the [MIT License](http://opensource.org/licenses/MIT).


## Contact

若有任何問題可以與我聯繫，也歡迎大家幫忙修正 CocoaCKIPClient！