#import "ZHStoryboardTextManager.h"
#import "ZHStroyBoardFileManager.h"
#import "ZHNSString.h"

static NSMutableDictionary *ZHStoryboardDicM;
static NSMutableDictionary *ZHStoryboardIDDicM;

@implementation ZHStoryboardTextManager
+ (NSMutableDictionary *)defaultDicM{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ZHStoryboardDicM==nil) {
            ZHStoryboardDicM=[NSMutableDictionary dictionary];
            
            NSMutableArray *viewsArr=[NSMutableArray array];
            [viewsArr addObject:@"<label "];
            [viewsArr addObject:@"<button "];
            [viewsArr addObject:@"<segmentedControl "];
            [viewsArr addObject:@"<textField "];
            [viewsArr addObject:@"<slider "];
            [viewsArr addObject:@"<tableViewCell "];
            [viewsArr addObject:@"<collectionViewCell "];
            [viewsArr addObject:@"<switch "];
            [viewsArr addObject:@"<activityIndicatorView "];
            [viewsArr addObject:@"<progressView "];
            [viewsArr addObject:@"<pageControl "];
            [viewsArr addObject:@"<stepper "];
            [viewsArr addObject:@"<tableView "];
            [viewsArr addObject:@"<imageView "];
            [viewsArr addObject:@"<collectionView "];
            [viewsArr addObject:@"<textView "];
            [viewsArr addObject:@"<scrollView "];
            [viewsArr addObject:@"<datePicker "];
            [viewsArr addObject:@"<pickerView "];
            [viewsArr addObject:@"<mapView "];
            [viewsArr addObject:@"<view "];
            [viewsArr addObject:@"<searchBar "];
            [viewsArr addObject:@"<webView "];
            [viewsArr addObject:@"<self.view "];//特殊标识符
            [viewsArr addObject:@"<viewController "];////特殊标识符
            
            for (NSString *str in viewsArr) {
                [ZHStoryboardDicM setValue:[NSNumber numberWithInteger:0] forKey:str];
            }
        }
    });
    return ZHStoryboardDicM;
}
+ (NSMutableDictionary *)defaultIDDicM{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ZHStoryboardIDDicM==nil) {
            ZHStoryboardIDDicM=[NSMutableDictionary dictionary];
        }
    });
    return ZHStoryboardIDDicM;
}

+ (void)done{
    [ZHStoryboardIDDicM removeAllObjects];
    
    for (NSString *str in [[self defaultDicM] allKeys]) {
        [ZHStoryboardDicM setValue:[NSNumber numberWithInteger:0] forKey:str];
    }
}

+ (NSInteger)getAllViewCount{
    NSMutableArray *viewsArr=[NSMutableArray array];
    [viewsArr addObject:@"<label "];
    [viewsArr addObject:@"<button "];
    [viewsArr addObject:@"<segmentedControl "];
    [viewsArr addObject:@"<textField "];
    [viewsArr addObject:@"<slider "];
    [viewsArr addObject:@"<tableViewCell "];
    [viewsArr addObject:@"<collectionViewCell "];
    [viewsArr addObject:@"<switch "];
    [viewsArr addObject:@"<activityIndicatorView "];
    [viewsArr addObject:@"<progressView "];
    [viewsArr addObject:@"<pageControl "];
    [viewsArr addObject:@"<stepper "];
    [viewsArr addObject:@"<tableView "];
    [viewsArr addObject:@"<imageView "];
    [viewsArr addObject:@"<collectionView "];
    [viewsArr addObject:@"<textView "];
    [viewsArr addObject:@"<scrollView "];
    [viewsArr addObject:@"<datePicker "];
    [viewsArr addObject:@"<pickerView "];
    [viewsArr addObject:@"<mapView "];
    [viewsArr addObject:@"<view "];
    [viewsArr addObject:@"<searchBar "];
    [viewsArr addObject:@"<webView "];
    
    NSInteger count=0;
    for (NSString *str in viewsArr) {
        NSNumber *num=ZHStoryboardDicM[str];
        count+=[num integerValue];
    }
    return count;
}

/**为View打上所有标识符(默认顺序)*/
+ (NSString *)addCustomClassToAllViews:(NSString *)text{
    return [self addCustomClass:text needDealAdapterCell:YES];
}
+ (NSString *)addCustomClassToAllViewsForPureHandProject:(NSString *)text{
    return [self addCustomClass:text needDealAdapterCell:NO];
}
+ (NSString *)addCustomClass:(NSString *)text needDealAdapterCell:(BOOL)needDealAdapterCell{
    NSArray *arr=[text componentsSeparatedByString:@"\n"];
    NSMutableArray *arrM=[NSMutableArray array];
    NSString *rowStr,*newRowStr,*viewIdenity;
    
    NSMutableDictionary *conectionDic = [NSMutableDictionary new];
    // 保存一下 IBAction 的连接
    // property="VRImageView" destination="yFw-Yh-1qk"
    
    // 获取 fd_collapsibleConstraints
    NSMutableArray *FDDic = [NSMutableArray new];
    for (NSInteger i=0; i<arr.count; i++) {
        rowStr=arr[i];
        NSString * text=[ZHNSString removeSpaceBeforeAndAfterWithString:rowStr];
        if ([text hasPrefix:@"<outlet"]) {
            // 是连线
            if (([rowStr rangeOfString:@"property=\""].location!=NSNotFound)&& ([rowStr rangeOfString:@"destination=\""].location!=NSNotFound)) {
                // proerty: VRImageView
                NSString *property=[rowStr substringFromIndex:[rowStr rangeOfString:@"property=\""].location+10];
                property=[property substringToIndex:[property rangeOfString:@"\""].location];
                
                // destination: yFw-Yh-1qk 对应 xib 上具体的控件 id
                NSString *destination=[rowStr substringFromIndex:[rowStr rangeOfString:@"destination=\""].location+13];
                destination=[destination substringToIndex:[destination rangeOfString:@"\""].location];
                [conectionDic setValue:property forKey:destination];
            }
        }
        
        if ([text hasPrefix:@"<outletCollection"]) {
            
            if (([rowStr rangeOfString:@"property=\""].location!=NSNotFound)&& ([rowStr rangeOfString:@"destination=\""].location!=NSNotFound)) {
                
                NSString *property=[rowStr substringFromIndex:[rowStr rangeOfString:@"property=\""].location+10];
                property=[property substringToIndex:[property rangeOfString:@"\""].location];
                
                if ([property isEqualToString:@"fd_collapsibleConstraints"]) {
                    NSString *destination=[rowStr substringFromIndex:[rowStr rangeOfString:@"destination=\""].location+13];
                    destination=[destination substringToIndex:[destination rangeOfString:@"\""].location];
                    [FDDic addObject:destination];
                }
            }
        }
    }
    
    for (NSInteger i=0; i<arr.count; i++) {
        rowStr=arr[i];
        
        viewIdenity=[self isView:rowStr];
        //如果这一行代表的是控件
        if (viewIdenity.length>0) {
            if ([viewIdenity isEqualToString:@"<view "]&&i>0&&([arr[i-1] rangeOfString:@"key=\""].location!=NSNotFound||[arr[i-1] rangeOfString:@"</layoutGuides>"].location!=NSNotFound)) {
                
                //为了后面好设置约束,需要将这类view的id值设成特殊可识别的标识符
                //取出id值
                if ([rowStr rangeOfString:@"id=\""].location!=NSNotFound) {
                    NSString *idStr=[rowStr substringFromIndex:[rowStr rangeOfString:@"id=\""].location+4];
                    idStr=[idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                    NSString *viewCountIdenity=[self getViewCountIdenityWithViewIdenity:@"<self.view "];
                    
                    if ([conectionDic containsObjectForKey:idStr]) {
                        viewCountIdenity = [conectionDic objectForKey:idStr];
                    }
                    
                    [[self defaultIDDicM]setValue:idStr forKey:viewCountIdenity];
                }
                [arrM addObject:[self replaceAllIdByCustomClass:rowStr]];
                continue;
            }
            
            //如果这一行里面没有标识符CustomClass
            if ([rowStr rangeOfString:@" userLabel"].location==NSNotFound) {
                
                if ([rowStr hasSuffix:@">"]==YES) {
                    newRowStr=[rowStr substringToIndex:rowStr.length-1];
                    NSString *viewCountIdenity=[self getViewCountIdenityWithViewIdenity:viewIdenity];
                    
                    NSString *idStr=[newRowStr substringFromIndex:[newRowStr rangeOfString:@"id=\""].location+4];
                    idStr=[idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                    
                    if ([conectionDic containsObjectForKey:idStr]) {
                        viewCountIdenity = [conectionDic objectForKey:idStr];
                    }
                    
                    newRowStr=[newRowStr stringByAppendingFormat:@" userLabel=\"%@\">",viewCountIdenity];
                    
                    
                    if ([newRowStr rangeOfString:@" userLabel=\""].location!=NSNotFound&&[newRowStr rangeOfString:@" id=\""].location!=NSNotFound) {
                        NSString *customClass=[newRowStr substringFromIndex:[newRowStr rangeOfString:@"userLabel=\""].location+11];
                        customClass=[customClass substringToIndex:[customClass rangeOfString:@"\""].location];
                        //                        NSLog(@"customClass=%@",customClass);
                        
                        
                        [[self defaultIDDicM]setValue:idStr forKey:customClass];
                        
                    }else{
                        NSLog(@"出现小BUG 有的view没有打CustomClass =%@",newRowStr);
                    }
                    
                    [arrM addObject:[self replaceAllIdByCustomClass:newRowStr]];
                    continue;
                }
            }else if ([rowStr rangeOfString:@" userLabel=\""].location!=NSNotFound&&[rowStr rangeOfString:@" id=\""].location!=NSNotFound) {
                NSString *customClass=[rowStr substringFromIndex:[rowStr rangeOfString:@"userLabel=\""].location+11];
                customClass=[customClass substringToIndex:[customClass rangeOfString:@"\""].location];
                NSString *newCustomClass;
                if (needDealAdapterCell) {
                    newCustomClass=[self detailSpecialCustomClassLikeCell:rowStr];
                }else{
                    newCustomClass=[self noDetailSpecialCustomClassLikeCell:rowStr];
                }
                if (newCustomClass.length>0) {
                    //替换
                    NSString *oldCustom=[@" userLabel=\"" stringByAppendingString:customClass];
                    NSString *newCustom=[@" userLabel=\"" stringByAppendingString:newCustomClass];
                    rowStr=[rowStr stringByReplacingOccurrencesOfString:oldCustom withString:newCustom];
                    customClass=newCustomClass;
                }
                
                //                                NSLog(@"customClass=%@",customClass);
                
                NSString *idStr=[rowStr substringFromIndex:[rowStr rangeOfString:@"id=\""].location+4];
                idStr=[idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                //                                NSLog(@"idStr=%@",idStr);
                if ([conectionDic containsObjectForKey:idStr]) {
                    customClass = [conectionDic objectForKey:idStr];
                }
                
                [[self defaultIDDicM]setValue:idStr forKey:customClass];
            }else{
                NSLog(@"出现小BUG 有的view没有打CustomClass =%@",rowStr);
            }
        }else{
            
            //如果不是控件,就判断是不是ViewController,因为如果是的,就可以清空 CustomClass 和 id 的字典了
            
            NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:rowStr];
            if([tempStr hasPrefix:@"<viewController "]){
                [[self defaultIDDicM] removeAllObjects];
                
                //如果没有打上标识符
                if([tempStr rangeOfString:@" userLabel=\""].location==NSNotFound){
                    
                    if ([tempStr hasSuffix:@"sceneMemberID=\"viewController\">"]) {
                        NSString *newRowStr=[rowStr stringByReplacingOccurrencesOfString:@"sceneMemberID=\"viewController\">" withString:@""];
                        NSString *viewCountIdenity=[self getViewCountIdenityWithViewIdenity:@"<viewController "];
                        NSString *idStr=[newRowStr substringFromIndex:[newRowStr rangeOfString:@"id=\""].location+4];
                        idStr=[idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                        if ([conectionDic containsObjectForKey:idStr]) {
                            viewCountIdenity = [conectionDic objectForKey:idStr];
                        }
                        
                        newRowStr=[newRowStr stringByAppendingString:[NSString stringWithFormat:@"userLabel=\"%@\"",viewCountIdenity]];
                        newRowStr=[newRowStr stringByAppendingString:@" sceneMemberID=\"viewController\">"];
                        [arrM addObject:[self replaceAllIdByCustomClass:newRowStr]];
                        continue;
                    }
                }
            }
        }
        // 处理 fd_collapsibleConstraints
        for (NSString *fd_collapsibleConstraintsId in FDDic) {
            rowStr=[rowStr stringByReplacingOccurrencesOfString:fd_collapsibleConstraintsId withString:[NSString stringWithFormat:@"fd_collapsibleConstraintsId\" isFD=\"1"]];
        }
        [arrM addObject:[self replaceAllIdByCustomClass:rowStr]];
    }
    return [arrM componentsJoinedByString:@"\n"];
}
/**为所有view的id打上标识符,对应的标识符就是CustomClass*/
+ (NSString *)replaceAllIdByCustomClass:(NSString *)text{
    for (NSString *customClass in [self defaultIDDicM]) {
        text=[text stringByReplacingOccurrencesOfString:[self defaultIDDicM][customClass] withString:customClass];
    }
    return text;
}

+ (NSString *)isView:(NSString *)text{
    
    NSMutableArray *viewsArr=[NSMutableArray array];
    [viewsArr addObject:@"<label "];
    [viewsArr addObject:@"<button "];
    [viewsArr addObject:@"<imageView "];
    [viewsArr addObject:@"<tableView "];
    [viewsArr addObject:@"<tableViewCell "];
    [viewsArr addObject:@"<collectionView "];
    [viewsArr addObject:@"<collectionViewCell "];
    [viewsArr addObject:@"<view "];
    [viewsArr addObject:@"<segmentedControl "];
    [viewsArr addObject:@"<textField "];
    [viewsArr addObject:@"<slider "];
    [viewsArr addObject:@"<switch "];
    [viewsArr addObject:@"<activityIndicatorView "];
    [viewsArr addObject:@"<progressView "];
    [viewsArr addObject:@"<pageControl "];
    [viewsArr addObject:@"<stepper "];
    [viewsArr addObject:@"<textView "];
    [viewsArr addObject:@"<scrollView "];
    [viewsArr addObject:@"<datePicker "];
    [viewsArr addObject:@"<pickerView "];
    [viewsArr addObject:@"<mapView "];
    [viewsArr addObject:@"<searchBar "];
    [viewsArr addObject:@"<webView "];
    NSString *newStr;
    
    text=[ZHNSString removeSpaceBeforeAndAfterWithString:text];
    for (NSString *str in viewsArr) {
        if ([text hasPrefix:str]) {
            newStr=str;
            return newStr;
        }
    }
    
    return @"";
}

//viewCategory 控件的真名类别  viewName控件customClass的属性值
+ (NSString *)getPropertyWithViewName:(NSString *)viewName withViewCategory:(NSString *)viewCategory{
    //如果有数字结尾,就不产生属性代码
//    unichar ch=[viewName characterAtIndex:viewName.length-1];
//    if (ch>='0'&&ch<='9') {
//        return @"";
//    }
    
    if([viewCategory isEqualToString:@"tableView"]||[viewCategory isEqualToString:@"collectionView"]){
        return @"";
    }
    
    //第一个字母大写
    viewCategory=[self upFirstCharacter:viewCategory];
    
    return [NSString stringWithFormat:@"@property (strong, nonatomic) UI%@ *%@;",viewCategory,viewName];
}

//viewCategory 控件的真名类别  viewName控件customClass的属性值
+ (NSString *)getPropertyWithViewName_XIB:(NSString *)viewName withViewCategory:(NSString *)viewCategory isOnlyTableViewOrCollectionView:(BOOL)isOnlyTableViewOrCollectionView{
    //如果有数字结尾,就不产生属性代码
    //    unichar ch=[viewName characterAtIndex:viewName.length-1];
    //    if (ch>='0'&&ch<='9') {
    //        return @"";
    //    }
    if(isOnlyTableViewOrCollectionView){
        if([viewCategory isEqualToString:@"tableView"]){
            viewName=@"tableView";
        }
        if([viewCategory isEqualToString:@"collectionView"]){
            viewName=@"collectionView";
        }
    }
    
//    //第一个字母大写
//    viewCategory=[self upFirstCharacter:viewCategory];
    BOOL hasUiPrefix = [viewCategory hasPrefix:@"UI"];
    NSString *watching = hasUiPrefix?@"":@" // 注意添加头文件";
    return [NSString stringWithFormat:@"@property (strong, nonatomic) %@ *%@;%@",viewCategory,viewName,watching];
}

/**替换所有的约束的.constant=;*/
+ (void)replaceConstantToMasonry:(NSDictionary *)replaceMasonryDic ToStrM:(NSMutableString *)text{
//    bgViewHeight = "[self.view14 mas_updateConstraints:^(MASConstraintMaker *make) {\n                make.height.equalTo(@($replace$));\n                 }];";
//    if (replaceMasonryDic.count>0) {
//        NSLog(@"%@",replaceMasonryDic);
//    }
    
    
    for (NSString *property in replaceMasonryDic) {
        if ([text rangeOfString:[NSString stringWithFormat:@"%@.constant",property]].location!=NSNotFound) {
            [self subReplaceConstantWithProperty:property ToStrM:text withReplaceMasonryDic:replaceMasonryDic];
        }
    }
}

/**替换所有的约束的.constant=;*/
+ (void)subReplaceConstantWithProperty:(NSString *)property ToStrM:(NSMutableString *)text withReplaceMasonryDic:(NSDictionary *)replaceMasonryDic{
    if ([text rangeOfString:[NSString stringWithFormat:@"%@.constant=",property]].location!=NSNotFound) {
        NSString *textTemp=[NSString stringWithString:text];
        textTemp=[self removeDocSpace:textTemp];
        
        BOOL prefixAdd=NO;//前面是不是还有等于号
        if ([textTemp rangeOfString:[NSString stringWithFormat:@"self.%@.constant=",property]].location!=NSNotFound) {
            NSInteger start=[textTemp rangeOfString:[NSString stringWithFormat:@"self.%@.constant=",property]].location;
            NSInteger end=start+[NSString stringWithFormat:@"self.%@.constant=",property].length;
            unichar ch;
            for (NSInteger i=end+1; i<textTemp.length; i++) {
                ch=[textTemp characterAtIndex:i];
                end++;
                if (ch==';') {
                    break;
                }
            }
            if (start>0) {
                unichar ch1=[textTemp characterAtIndex:start-1];
                if (ch1=='=') {
                    prefixAdd=YES;
                }
            }
            
            NSString *constantCode=[textTemp substringWithRange:NSMakeRange(start, end-start+1)];
            
            NSMutableArray *arrMTemp=[NSMutableArray array];
            for (NSString *str in [constantCode componentsSeparatedByString:@"="]) {
                if ([arrMTemp containsObject:str]==NO) {
                    [arrMTemp addObject:str];
                }
            }
            if (arrMTemp.count>=2) {
                NSString *lastObj=arrMTemp[arrMTemp.count-1];
                [arrMTemp removeObject:lastObj];
                lastObj=[lastObj stringByReplacingOccurrencesOfString:@" " withString:@""];
                lastObj=[lastObj stringByReplacingOccurrencesOfString:@";" withString:@""];
                for (NSString *str in arrMTemp) {
                    NSString *tempObj=str;
                    if ([tempObj hasPrefix:@"_"]) {
                        tempObj=[tempObj substringFromIndex:1];
                    }
                    tempObj=[tempObj stringByReplacingOccurrencesOfString:@"self." withString:@""];
                    tempObj=[tempObj stringByReplacingOccurrencesOfString:@".constant" withString:@""];
                    
                    NSString *replaceMasonryStr=replaceMasonryDic[tempObj];
                    replaceMasonryStr = [replaceMasonryStr stringByReplacingOccurrencesOfString:@"$replace$" withString:lastObj];
                    
                    if (prefixAdd==YES) {
                        replaceMasonryStr=[[NSString stringWithFormat:@"%@;\n",lastObj] stringByAppendingString:replaceMasonryStr];
                    }
//                    NSLog(@"--------------");
//                    NSLog(@"textTemp=%@",textTemp);
//                    NSLog(@"constantCode=%@",constantCode);
//                    NSLog(@"replaceMasonryStr=%@",replaceMasonryStr);
                    
                    if (replaceMasonryStr.length>0) {
                        textTemp =[textTemp stringByReplacingOccurrencesOfString:constantCode withString:replaceMasonryStr];
                    }
                }
            }
            
            [text setString:textTemp];
            [self subReplaceConstantWithProperty:property ToStrM:text withReplaceMasonryDic:replaceMasonryDic];
        }
        
        if ([textTemp rangeOfString:[NSString stringWithFormat:@"_%@.constant=",property]].location!=NSNotFound) {
            NSInteger start=[textTemp rangeOfString:[NSString stringWithFormat:@"_.%@.constant=",property]].location;
            NSInteger end=start+[NSString stringWithFormat:@"_.%@.constant=",property].length;
            unichar ch;
            for (NSInteger i=end+1; i<textTemp.length; i++) {
                ch=[textTemp characterAtIndex:i];
                end++;
                if (ch==';') {
                    break;
                }
            }
            if (start>0) {
                unichar ch1=[textTemp characterAtIndex:start-1];
                if (ch1=='=') {
                    prefixAdd=YES;
                }
            }
            NSString *constantCode=[textTemp substringWithRange:NSMakeRange(start, end-start+1)];
            
            NSMutableArray *arrMTemp=[NSMutableArray array];
            for (NSString *str in [constantCode componentsSeparatedByString:@"="]) {
                if ([arrMTemp containsObject:str]==NO) {
                    [arrMTemp addObject:str];
                }
            }
            if (arrMTemp.count>=2) {
                NSString *lastObj=arrMTemp[arrMTemp.count-1];
                [arrMTemp removeObject:lastObj];
                lastObj=[lastObj stringByReplacingOccurrencesOfString:@" " withString:@""];
                lastObj=[lastObj stringByReplacingOccurrencesOfString:@";" withString:@""];
                for (NSString *str in arrMTemp) {
                    NSString *tempObj=str;
                    if ([tempObj hasPrefix:@"_"]) {
                        tempObj=[tempObj substringFromIndex:1];
                    }
                    tempObj=[tempObj stringByReplacingOccurrencesOfString:@"self." withString:@""];
                    tempObj=[tempObj stringByReplacingOccurrencesOfString:@".constant" withString:@""];
                    
                    NSString *replaceMasonryStr=replaceMasonryDic[tempObj];
                    replaceMasonryStr = [replaceMasonryStr stringByReplacingOccurrencesOfString:@"$replace$" withString:lastObj];
                    
                    if (prefixAdd==YES) {
                        replaceMasonryStr=[[NSString stringWithFormat:@"%@;\n",lastObj] stringByAppendingString:replaceMasonryStr];
                    }
                    
                    textTemp =[textTemp stringByReplacingOccurrencesOfString:constantCode withString:replaceMasonryStr];
                }
                
            }
            
            textTemp =[textTemp stringByReplacingOccurrencesOfString:constantCode withString:@""];
            
            [text setString:textTemp];
            [self subReplaceConstantWithProperty:property ToStrM:text withReplaceMasonryDic:replaceMasonryDic];
        }
    }
}

+ (NSString *)removeDocSpace:(NSString *)text{
    if ([text rangeOfString:@". "].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@". " withString:@"."];
        return [self removeDocSpace:text];
    }
    if ([text rangeOfString:@" ."].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@" ." withString:@"."];
        return [self removeDocSpace:text];
    }
    if ([text rangeOfString:@" ="].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@" =" withString:@"="];
        return [self removeDocSpace:text];
    }
    if ([text rangeOfString:@"= "].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@"= " withString:@"="];
        return [self removeDocSpace:text];
    }
    return text;
}

/**在这里,取出拉线出来的约束,并且拿到当为这个约束赋值时的代码改成masonry对应的代码*/
+ (NSDictionary *)getUpdataMasonryCodeWithViewConstraintDic:(NSDictionary *)viewConstraintDic withOutletView:(NSDictionary *)outletView{
    
    NSMutableArray *shouldOutlet=[NSMutableArray array];
    NSMutableDictionary *replaceMasonry=[NSMutableDictionary dictionary];
    
    //遍历这个控件的所有约束,看是否有的约束已经拉线出来的
    for (NSString *view in viewConstraintDic) {
        for ( NSDictionary *subDic in viewConstraintDic[view]) {
            if (outletView[subDic[@"id"]]!=nil) {
                NSString *firstAttribute=subDic[@"firstAttribute"];
                NSString *property=outletView[subDic[@"id"]];
                NSString *myView=outletView[view];
                if (myView.length<=0) {
                    if ([shouldOutlet containsObject:view]==NO) {
                        [shouldOutlet addObject:view];
                    }
                    myView=view;
                }
                NSString *replace=[NSString stringWithFormat:@"[self.%@ mas_updateConstraints:^(MASConstraintMaker *make) { make.%@.equalTo(@($replace$)); }];",myView,firstAttribute];
                [replaceMasonry setValue:replace forKey:property];
            }
        }
    }
    
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    [dicM setValue:shouldOutlet forKey:@"shouldOutlet"];
    [dicM setValue:replaceMasonry forKey:@"replaceMasonry"];
    return dicM;
}

/**获取引用某个view的代码*/
+ (NSString *)getOutletViewCodeWithView:(NSString *)view withViewCategoryName:(NSString *)viewCategoryName{
    if ([viewCategoryName isEqualToString:@"mapView"]) {
        [NSString stringWithFormat:@"@property (strong, nonatomic) MK%@ *%@;",[self upFirstCharacter:viewCategoryName],view];
    }
    return [NSString stringWithFormat:@"@property (strong, nonatomic) UI%@ *%@;",[self upFirstCharacter:viewCategoryName],view];
}


/**
 addSubview

 @param viewName 子属视图
 @param fatherView 父视图
 @return 添加代码
 */
+ (NSString *)getAddSubviewWithViewName:(NSString *)viewName addToFatherView:(NSString *)fatherView{
    NSString *addString = @"";
    
    BOOL hasSelf = [fatherView hasPrefix:@"self."];
    NSString *prefix = hasSelf?@"":@"self.";
    addString = [NSString stringWithFormat:@"[%@%@ addSubview:self.%@];\n\n",prefix,fatherView,viewName];
    
    return addString;
}
/**获取创建某个view的代码*/
+ (NSString *)getCreateViewCodeWithIdStr:(NSString *)idStr WithViewName:(NSString *)viewName withViewCategoryName:(NSString *)viewCategoryName withOutletView:(NSDictionary *)outletView addToFatherView:(NSString *)fatherView withDoneArrM:(NSMutableArray *)doneArrM isOnlyTableViewOrCollectionView:(BOOL)isOnlyTableViewOrCollectionView withIdAndOutletViewsDic:(NSDictionary *)idAndOutletViews{
    
    NSMutableString *textCode=[NSMutableString string];
    
    if ([doneArrM containsObject:viewName]) {
        return @"";
    }
    if ([viewName hasPrefix:@"self."]) {
        return @"";
    }
    if ([viewCategoryName isEqualToString:@"button"]) {
        [textCode appendFormat:@"UIButton *%@=[UIButton buttonWithType:(UIButtonTypeSystem)];\n",viewName];
    }else if([viewCategoryName isEqualToString:@"tableView"]){
        [textCode appendFormat:@"UITableView *%@=[[UITableView alloc]initWithFrame:CGRectZero style:(UITableViewStylePlain)];\n",viewName];
    }else if([viewCategoryName isEqualToString:@"collectionView"]){
        [textCode appendFormat:@"UICollectionViewFlowLayout *flow%@ = [UICollectionViewFlowLayout new];\n",[self upFirstCharacter:viewName]];
        [textCode appendFormat:@"//flow%@.scrollDirection = UICollectionViewScrollDirectionHorizontal;//水平\n\
         flow%@.scrollDirection = UICollectionViewScrollDirectionVertical;//垂直\n\
         flow%@.minimumInteritemSpacing = 0;\n\
         flow%@.minimumLineSpacing = 0;\n\n",[self upFirstCharacter:viewName],[self upFirstCharacter:viewName],[self upFirstCharacter:viewName],[self upFirstCharacter:viewName]];
        [textCode appendFormat:@"UICollectionView *%@=[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flow%@];\n",viewName,[self upFirstCharacter:viewName]];
        [textCode appendFormat:@"%@.backgroundColor=[UIColor whiteColor];\n\
         //%@.contentInset=UIEdgeInsetsMake(10, 10, 10, 10);\n",viewName,viewName];
    }else{
        [textCode appendFormat:@"UI%@ *%@=[UI%@ new];\n",[self upFirstCharacter:viewCategoryName],viewName,[self upFirstCharacter:viewCategoryName]];
    }
    [doneArrM addObject:viewName];
    NSString *realViewName=@"";
    if (idAndOutletViews!=nil) {
        if (idAndOutletViews[viewName]!=nil) {
            realViewName=idAndOutletViews[viewName];
        }
    }
    if (outletView!=nil&&outletView.count>0) {
        if (outletView[idStr]!=nil&&[(NSString *)outletView[idStr] length]>0) {
            [textCode appendFormat:@"[%@ addSubview:%@];\nself.%@=%@;\n\n",fatherView,realViewName.length>0?realViewName:viewName,outletView[idStr],viewName];
        }else{
            [textCode appendFormat:@"[%@ addSubview:%@];\n\n",fatherView,viewName];
        }
    }else{
        [textCode appendFormat:@"[%@ addSubview:%@];\nself.%@=%@;\n\n",fatherView,viewName,realViewName.length>0?realViewName:viewName,viewName];
    }
    
    return textCode;
}

+ (NSString *)getFatherView:(NSString *)view inViewRelationShipDic:(NSDictionary *)viewRelationShipDic{
    for (NSString *fatherView in viewRelationShipDic) {
        NSArray *subViews=viewRelationShipDic[fatherView];
        if ([subViews containsObject:view]) {
            return fatherView;
        }
    }
    return @"";
}

/**判断是不是系统自动打上的标识符*/
+ (BOOL)isSystemIdStr:(NSString *)idStr{
    if (idStr.length==10) {
        unichar ch1,ch2;
        ch1=[idStr characterAtIndex:3];
        ch2=[idStr characterAtIndex:6];
        if (ch1=='-'&&ch2=='-') {
            return YES;
        }
    }
    return NO;
}

/**创建约束代码*/
+ (NSString *)getCreatConstraintCodeWithIdStr:(NSString *)idStr WithViewName:(NSString *)viewName withConstraintDic:(NSDictionary *)constraintDic withSelfConstraintDic:(NSDictionary *)selfConstraintDic withOutletView:(NSDictionary *)outletView isCell:(BOOL)isCell withDoneArrM:(NSMutableArray *)doneArrM withCustomAndNameDic:(NSDictionary *)customAndNameDic addToFatherView:(NSString *)fatherView isOnlyTableViewOrCollectionView:(BOOL)isOnlyTableViewOrCollectionView withIdAndOutletViewsDic:(NSDictionary *)idAndOutletViews{
    
    NSMutableString *textCode=[NSMutableString string];
    
    [textCode appendFormat:@"[%@ mas_makeConstraints:^(MASConstraintMaker *make) {\n",viewName];
    
    NSArray *constraintArr=constraintDic[viewName];
    if (constraintArr.count>0) {
        for (NSDictionary *constraintSubDic in constraintArr) {
            
//            NSLog(@"%@:%@",viewName,constraintSubDic);
            
            //每一个具体的约束
            
            NSString *firstAttribute=constraintSubDic[@"firstAttribute"];
            NSString *firstItem=constraintSubDic[@"firstItem"];
            NSString *secondAttribute=constraintSubDic[@"secondAttribute"];
            NSString *secondItem=constraintSubDic[@"secondItem"];
            NSString *multiplier=constraintSubDic[@"multiplier"];
            NSString *constant=constraintSubDic[@"constant"];
            NSString *idStr=constraintSubDic[@"id"];
            
            if ([firstItem hasPrefix:@"self.view"]) {
                firstItem=@"self.view";
            }
            if ([secondItem hasPrefix:@"self.view"]) {
                secondItem=@"self.view";
            }
            
            if ([firstItem hasSuffix:@"CollectionViewCell"]||[firstItem hasSuffix:@"TableViewCell"]) {
                firstItem=@"self.contentView";
            }
            if ([secondItem hasSuffix:@"CollectionViewCell"]||[secondItem hasSuffix:@"TableViewCell"]) {
                secondItem=@"self.contentView";
            }
            
            if([self isSystemIdStr:firstItem]){
                if (isCell) {
                    firstItem=@"self.contentView";
                }else{
                    firstItem=fatherView;
                }
            }else{
                if (firstItem.length>0&&[self isView:firstItem]&&[firstItem isEqual:@"self.view"]==NO&&[firstItem isEqual:@"self.contentView"]==NO&&[doneArrM containsObject:firstItem]==NO) {
                    [textCode insertString:[self getCreateViewCodeWithIdStr:firstItem WithViewName:firstItem withViewCategoryName:customAndNameDic[firstItem] withOutletView:outletView addToFatherView:fatherView withDoneArrM:doneArrM isOnlyTableViewOrCollectionView:isOnlyTableViewOrCollectionView withIdAndOutletViewsDic:idAndOutletViews] atIndex:0];
                }
            }
            
            if([self isSystemIdStr:secondItem]){
                if (isCell) {
                    secondItem=@"self.contentView";
                }else{
                    secondItem=fatherView;
                }
            }else{
                if (secondItem.length>0&&[self isView:secondItem]&&[secondItem isEqual:@"self.view"]==NO&&[firstItem isEqual:@"self.contentView"]==NO&&[doneArrM containsObject:secondItem]==NO) {
                    [textCode insertString:[self getCreateViewCodeWithIdStr:secondItem WithViewName:secondItem withViewCategoryName:customAndNameDic[secondItem] withOutletView:outletView addToFatherView:fatherView withDoneArrM:doneArrM isOnlyTableViewOrCollectionView:isOnlyTableViewOrCollectionView withIdAndOutletViewsDic:idAndOutletViews] atIndex:0];
                }
            }
 
            //1.如果该约束的第一对象是自己
            if ([firstItem isEqualToString:viewName]) {
                
                if (secondItem.length>0) {//第2对象存在
                    
                    if(secondAttribute.length>0){
                        if ([secondItem hasPrefix:@"self."]) {
                            if(constant.length>0){
                                if ([firstAttribute isEqualToString:@"trailing"]||[firstAttribute isEqualToString:@"bottom"]) {
//                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@).with.offset(%@)",firstAttribute,secondItem,firstAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",firstAttribute,secondItem,firstAttribute];
                            }
                        }else{
                            if(constant.length>0){
                                if (([firstAttribute isEqualToString:@"trailing"]||[firstAttribute isEqualToString:@"bottom"])&&[firstAttribute isEqualToString:secondAttribute]) {
//                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@).with.offset(%@)",firstAttribute,secondItem,secondAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",firstAttribute,secondItem,secondAttribute];
                            }
                        }
                        
                    }else{
                        NSLog(@"%@",@"约束很奇怪  有secondItem 没有 secondAttribute");
                    }
                    
                }else{//第2对象不存在
                    if(constant.length>0){
                        [textCode appendFormat:@"make.%@.equalTo(@(%@))",firstAttribute,constant];
                    }else{
                        NSLog(@"%@",@"约束很奇怪  宽高没有值");
                    }
                }
                
            }
            else if ([secondItem isEqualToString:viewName]){
                
                if (firstItem.length>0&&[self isSystemIdStr:firstItem]==NO) {
                    if(firstAttribute.length>0){
                        
                        if ([firstItem hasPrefix:@"self."]) {
                            if(constant.length>0){
                                if ([secondAttribute isEqualToString:@"trailing"]||[secondAttribute hasPrefix:@"bottom"]) {
//                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@).with.offset(%@)",secondAttribute,firstItem,secondAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",secondAttribute,firstItem,secondAttribute];
                            }
                        }else{
                            if(constant.length>0){
                                if (([firstAttribute isEqualToString:@"trailing"]||[firstAttribute isEqualToString:@"bottom"])&&[firstAttribute isEqualToString:secondAttribute]) {
//                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@).with.offset(%@)",secondAttribute,firstItem,firstAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",secondAttribute,firstItem,firstAttribute];
                            }
                        }
                        
                    }else{
                        NSLog(@"%@",@"约束很奇怪  有firstItem 没有 firstAttribute");
                    }
                }else{
                    if (selfConstraintDic[viewName]!=nil) {
                        BOOL isSelfConstraint=NO;
                        for (NSDictionary *dicTemp in selfConstraintDic[viewName]) {
                            if([dicTemp[@"id"] isEqualToString:idStr]){
                                isSelfConstraint=YES;
                                break;
                            }
                        }
                        if (isSelfConstraint==YES) {
                            if (firstItem.length<=0) {
                                if (isCell) {
                                    firstItem=viewName;
                                }else{
                                    firstItem=fatherView;
                                }
                            }
                            if(constant.length>0){
                                if ([secondAttribute isEqualToString:@"trailing"]||[secondAttribute hasPrefix:@"bottom"]) {
//                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@).with.offset(%@)",secondAttribute,firstItem,firstAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",secondAttribute,firstItem,firstAttribute];
                            }
                        }else{
                            if (firstItem.length<=0) {
                                if (firstAttribute.length>0&&secondAttribute.length>0) {
                                    firstItem=fatherView;
                                }else{
                                    if (isCell) {
                                        firstItem=@"self.contentView";
                                    }else{
                                        firstItem=@"self.view";
                                    }
                                }
                            }
                            if(constant.length>0){
                                if ([secondAttribute isEqualToString:@"trailing"]||[secondAttribute hasPrefix:@"bottom"]) {
//                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@).with.offset(%@)",secondAttribute,firstItem,secondAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",secondAttribute,firstItem,secondAttribute];
                            }
                        }
                    }else{
                        if (firstItem.length<=0) {
                            if (firstAttribute.length>0&&secondAttribute.length>0) {
                                firstItem=fatherView;
                            }else{
                                if (isCell) {
                                    firstItem=@"self.contentView";
                                }else{
                                    firstItem=@"self.view";
                                }
                            }
                        }
                        if(constant.length>0){
                            if ([secondAttribute isEqualToString:@"trailing"]||[secondAttribute hasPrefix:@"bottom"]) {
//                                relation = [self checkRelation:relation reverse:YES];
                                constant=[@"-" stringByAppendingString:constant];
                            }
                            [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@).with.offset(%@)",secondAttribute,firstItem,secondAttribute,constant];
                        }else{
                            [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",secondAttribute,firstItem,secondAttribute];
                        }
                    }
                }
                
            }
            else{
                if (firstAttribute.length>0) {
                    [textCode appendFormat:@"make.%@.equalTo(@(%@))",firstAttribute,constant];
                }else{
                    NSLog(@"%@",@"约束很奇怪  没有firstAttribute");
                }
            }
            
            if(multiplier.length>0&&[multiplier isEqualToString:@"1"]==NO){
                [textCode appendFormat:@".multipliedBy(%@);\n",multiplier];
            }else{
                [textCode appendString:@";\n"];
            }
        }
    }
    
    
    [textCode appendString:@"}];\n\n\n"];
    
    //解决multipliedBy(m:n)的问题
    [self dealWith_multipliedBy:textCode];
    //解决.offset(--n)的问题
    [self dealWith_offset:textCode];
    return textCode;
}

//解决multipliedBy(m:n)的问题
+ (void)dealWith_multipliedBy:(NSMutableString *)textCode{
    NSArray *arr=[ZHNSString getMidStringBetweenLeftString:@"multipliedBy(" RightString:@")" withText:textCode getOne:NO withIndexStart:0 stopString:nil];
    
    NSString *text=[NSString stringWithString:textCode];
    NSString *newStr;
    for (NSString *str in arr) {
        if ([str rangeOfString:@":"].location!=NSNotFound) {
            newStr=[str stringByReplacingOccurrencesOfString:@":" withString:@"/"];
            newStr=[newStr stringByAppendingString:@".0"];
            
            text=[text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"multipliedBy(%@)",str] withString:[NSString stringWithFormat:@"multipliedBy(%@)",newStr]];
        }
    }
    if (arr.count>0) {
        [textCode setString:text];
    }
}

//解决.offset(--n)的问题  --得+
+ (void)dealWith_offset:(NSMutableString *)textCode{
    [textCode setString:[textCode stringByReplacingOccurrencesOfString:@".offset(--" withString:@".offset("]];
}

//解决self.tableView3=tableView3;的问题
+ (void)dealWith_self_tableView_collectionView:(NSMutableString *)textCode isOnlyTableViewOrCollectionView:(BOOL)isOnlyTableViewOrCollectionView{
    if (isOnlyTableViewOrCollectionView==NO) {
        return;
    }
    NSArray *tableViews=[ZHNSString getMidStringBetweenLeftString:@"UITableView *" RightString:@"=" withText:textCode getOne:NO withIndexStart:0 stopString:nil];
    NSArray *collectionViews=[ZHNSString getMidStringBetweenLeftString:@"UICollectionView *" RightString:@"=" withText:textCode getOne:NO withIndexStart:0 stopString:nil];
    
    NSString *text=[NSString stringWithString:textCode];
    
    for (NSString *str in tableViews) {
        if ([str hasPrefix:@"tableView"]) {
            text=[text stringByReplacingOccurrencesOfString:str withString:@"tableView"];
        }
    }
    
    for (NSString *str in collectionViews) {
        if ([str hasPrefix:@"collectionView"]) {
            text=[text stringByReplacingOccurrencesOfString:str withString:@"collectionView"];
        }
    }
    if (tableViews.count>0||collectionViews.count>0) {
        [textCode setString:text];
    }
}

//UIMapView *mapView1;
+ (void)dealWith_UIMapView:(NSMutableString *)textCode needInserFramework:(BOOL)needInserFramework{
    if ([textCode rangeOfString:@"UIMapView"].location==NSNotFound) {
        return;
    }
    
    if (needInserFramework) {
        [self addCodeText:@"#import <MapKit/MapKit.h>\n#error 请导入<MapKit.framework>框架" andInsertType:ZHAddCodeType_Import toStrM:textCode insertFunction:nil];
    }
    
    NSString *text=[NSString stringWithString:textCode];
    
    //开始替换
    text=[text stringByReplacingOccurrencesOfString:@"UIMapView" withString:@"MKMapView"];
    
    [textCode setString:text];
}

/**第一个字母大写*/
+ (NSString *)upFirstCharacter:(NSString *)text{
    if (text.length<=0) {
        return @"";
    }
    NSString *firstCharacter=[text substringToIndex:1];
    return [[firstCharacter uppercaseString] stringByAppendingString:[text substringFromIndex:1]];
}
/**第一个字母小写写*/
+ (NSString *)lowerFirstCharacter:(NSString *)text{
    if (text.length<=0) {
        return @"";
    }
    NSString *firstCharacter=[text substringToIndex:1];
    return [[firstCharacter lowercaseString] stringByAppendingString:[text substringFromIndex:1]];
}

+ (NSString *)detailSpecialCustomClassLikeCell:(NSString *)rowStr{
    NSMutableArray *viewsArr=[NSMutableArray array];
    [viewsArr addObject:@"<tableViewCell "];
    [viewsArr addObject:@"<collectionViewCell "];
    
    NSString *customClass=[rowStr substringFromIndex:[rowStr rangeOfString:@"userLabel=\""].location+11];
    customClass=[customClass substringToIndex:[customClass rangeOfString:@"\""].location];
    
    customClass=[ZHStroyBoardFileManager getAdapterCollectionViewCellAndTableViewCellName:customClass];
    
    NSString *newCustomClass;
    NSString *text=[ZHNSString removeSpaceBeforeAndAfterWithString:rowStr];
    for (NSString *str in viewsArr) {
        if ([text hasPrefix:str]) {
            newCustomClass=str;
            newCustomClass=[newCustomClass substringFromIndex:1];
            newCustomClass=[newCustomClass substringToIndex:newCustomClass.length-1];
            newCustomClass=[customClass stringByAppendingString:[self upFirstCharacter:newCustomClass]];
            break;
        }
    }
    return newCustomClass;
}

+ (NSString *)noDetailSpecialCustomClassLikeCell:(NSString *)rowStr{
    NSMutableArray *viewsArr=[NSMutableArray array];
    [viewsArr addObject:@"<tableViewCell "];
    [viewsArr addObject:@"<collectionViewCell "];
    
    NSString *customClass=[rowStr substringFromIndex:[rowStr rangeOfString:@"customClass=\""].location+13];
    customClass=[customClass substringToIndex:[customClass rangeOfString:@"\""].location];
    
    customClass=[ZHStroyBoardFileManager getAdapterCollectionViewCellAndTableViewCellNameForPureHandProject:customClass];
    
    NSString *newCustomClass;
    NSString *text=[ZHNSString removeSpaceBeforeAndAfterWithString:rowStr];
    for (NSString *str in viewsArr) {
        if ([text hasPrefix:str]) {
            
            newCustomClass=str;
            newCustomClass=[newCustomClass substringFromIndex:1];
            newCustomClass=[newCustomClass substringToIndex:newCustomClass.length-1];
            newCustomClass=[customClass stringByAppendingString:[self upFirstCharacter:newCustomClass]];
            
            //取出id 防止有些coder tableViewCell的关联文件和复用标识不一样
//            NSString *reuseIdentifier=[rowStr substringFromIndex:[rowStr rangeOfString:@"reuseIdentifier=\""].location+17];
//            reuseIdentifier=[reuseIdentifier substringToIndex:[reuseIdentifier rangeOfString:@"\""].location];
//            if([reuseIdentifier isEqualToString:newCustomClass]==NO){
//                newCustomClass=reuseIdentifier;
//            }
            break;
        }
    }
    
    return newCustomClass;
}

+ (NSString *)getViewCountIdenityWithViewIdenity:(NSString *)viewIdenity{
    NSString *viewCountIdenity=viewIdenity;
    if ([viewCountIdenity hasPrefix:@"<"]) {
        viewCountIdenity = [viewCountIdenity substringFromIndex:1];
    }
    if ([viewCountIdenity hasSuffix:@" "]) {
        viewCountIdenity = [viewCountIdenity substringToIndex:viewCountIdenity.length-1];
    }
    NSNumber *num=[self defaultDicM][viewIdenity];
    if (num) {
        NSInteger count=[num integerValue];
        
        //处理特殊的customClass，因为cell上一旦没有打上对应cell的标识，就会找不到文件，不好处理（TableviewCell，CollectionViewCell）
        
        NSArray *specialViews=@[@"tableViewCell",@"collectionViewCell"];
        
        NSString *specialViewFirst=@"";
        for (NSString *specialView in specialViews) {
            if ([viewCountIdenity hasPrefix:specialView]) {
                specialViewFirst=[[specialView substringToIndex:1] uppercaseString];
                break;
            }
        }
        
        if (specialViewFirst.length>0) {
            viewCountIdenity = [viewCountIdenity stringByAppendingFormat:@"%@%ld",specialViewFirst,count+1];
        }else
            viewCountIdenity = [viewCountIdenity stringByAppendingFormat:@"%ld",count+1];
        
        count++;
        [self defaultDicM][viewIdenity]=[NSNumber numberWithInteger:count];
        
        for (NSString *specialView in specialViews) {
            if ([viewCountIdenity hasPrefix:specialView]) {
                viewCountIdenity=[viewCountIdenity substringFromIndex:specialView.length];
                viewCountIdenity=[viewCountIdenity stringByAppendingString:[self upFirstCharacter:specialView]];
                break;
            }
        }
        
        return viewCountIdenity;
    }
    return viewCountIdenity;
}

/**判断是否是特殊控件*/
+ (BOOL)isTableViewOrCollectionView:(NSString *)text{
    text=[self removeSuffixNumber:text];
    if ([text isEqualToString:@"tableView"]||[text isEqualToString:@"collectionView"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isTableView:(NSString *)text{
    text=[self removeSuffixNumber:text];
    if ([text isEqualToString:@"tableView"]) {
        return YES;
    }
    return NO;
}
+ (BOOL)isCollectionView:(NSString *)text{
    text=[self removeSuffixNumber:text];
    if ([text isEqualToString:@"collectionView"]) {
        return YES;
    }
    return NO;
}
+ (NSInteger)getTableViewCount:(NSArray *)views{
    NSInteger count=0;
    for (NSString *view in views) {
        if ([self isTableView:view]) {
            count++;
        }
    }
    return count;
}
+ (NSInteger)getCollectionViewCount:(NSArray *)views{
    NSInteger count=0;
    for (NSString *view in views) {
        if ([self isCollectionView:view]) {
            count++;
        }
    }
    return count;
}
+ (NSArray *)getTableView:(NSArray *)views{
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSString *view in views) {
        if ([self isTableView:view]) {
            [arrM addObject:view];
        }
    }
    return arrM;
}
+ (NSArray *)getCollectionView:(NSArray *)views{
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSString *view in views) {
        if ([self isCollectionView:view]) {
            [arrM addObject:view];
        }
    }
    return arrM;
}
+ (BOOL)hasSuffixNumber:(NSString *)text{
    unichar ch=[text characterAtIndex:text.length-1];
    if (ch>='0'&&ch<='9') {
        return YES;
    }
    return NO;
}
+ (NSString *)removeSuffixNumber:(NSString *)text{
    unichar ch=[text characterAtIndex:text.length-1];
    while (ch>='0'&&ch<='9') {
        text=[text substringToIndex:text.length-1];
        ch=[text characterAtIndex:text.length-1];
    }
    return text;
}

/**往最某个代码后面追加*/
+ (BOOL)addCode:(NSString *)code ToTargetAfter:(NSString *)target toText:(NSMutableString *)text{
    if ([text rangeOfString:target].location==NSNotFound) {
        return NO;
    }
    
    NSInteger endIndex=[text rangeOfString:target].location+target.length;
    NSString *startString=[text substringToIndex:endIndex];
    NSString *endString=[text substringFromIndex:endIndex];
    
    NSMutableString *strM=[NSMutableString string];
    [strM appendString:startString];
    [strM appendString:@"\n"];
    [strM appendString:code];
    [strM appendString:@"\n"];
    [strM appendString:endString];
    [text setString:strM];
    
    return YES;
}

+ (void)addCodeText:(NSString *)code andInsertType:(ZHAddCodeType)insertType toStrM:(NSMutableString *)strM insertFunction:(NSString *)insertFunction{
    switch (insertType) {
        case ZHAddCodeType_Import:
            [self addCodeToImport:code toText:strM];
            break;
        case ZHAddCodeType_Interface:
            [self addCodeToFirstEnd:code toText:strM];
            break;
        case ZHAddCodeType_Implementation:
            [self addCodeToImplementation:code toText:strM];
            break;
        case ZHAddCodeType_InsertFunction:
            [self addCodeByReplaceFunction:code WithIdentity:insertFunction toText:strM];
            break;
        case ZHAddCodeType_end_last:
            [self addCodeToLastEnd:code toText:strM];
            break;
        case ZHAddCodeType_Delegate:
            [self addCodeToDelegate:code toText:strM];
            break;
    }
}

/**添加代理代码*/
+ (void)addCodeToDelegate:(NSString *)myCode toText:(NSMutableString *)text{
    
    NSInteger interfaceCount=[self getCountTargetString:@"@interface" inText:text];
    if (interfaceCount==0) {
        return;
    }
    
    NSInteger index=[text rangeOfString:@"interface"].location;
    if (index!=NSNotFound) {
        index=[text rangeOfString:@"()" options:NSLiteralSearch range:NSMakeRange(index, text.length-index)].location;
        if (index!=NSNotFound) {
            NSString *starText,*endText;
            starText=[text substringToIndex:index+2];
            endText=[text substringFromIndex:index+2];
            
            //如果之前没有添加过代理
            NSInteger historyIndex=index+2;
            index=[endText rangeOfString:@"<" options:NSLiteralSearch range:NSMakeRange(0, 30)].location;
            if (index==NSNotFound) {
                NSString *delegateStr=[NSString stringWithFormat:@"<%@>",myCode];
                NSMutableString *strM=[NSMutableString string];
                [strM appendString:starText];
                [strM appendString:delegateStr];
                [strM appendString:endText];
                
                [text setString:strM];
                return;
            }else{
                historyIndex+=index;
                NSInteger newIndex=[endText rangeOfString:myCode].location;
                if (newIndex==NSNotFound) {//如果该代理不存在,就添加
                    starText=[text substringToIndex:historyIndex+1];
                    endText=[text substringFromIndex:historyIndex+1];
                    
                    NSString *delegateStr=[NSString stringWithFormat:@"%@,",myCode];
                    NSMutableString *strM=[NSMutableString string];
                    [strM appendString:starText];
                    [strM appendString:delegateStr];
                    [strM appendString:endText];
                    [text setString:strM];
                    return;
                }
            }
        }
    }
    
}

/**往最后面的那个@end代码块中添加函数代码*/
+ (void)addCodeToLastEnd:(NSString *)myCode toText:(NSMutableString *)text{
    NSInteger endIndex=[text rangeOfString:@"@end" options:NSBackwardsSearch|NSLiteralSearch].location;
    if (endIndex!=NSNotFound) {
        NSString *startString=[text substringToIndex:endIndex];
        NSString *endString=[text substringFromIndex:endIndex];
        NSMutableString *strM=[NSMutableString string];
        [strM appendString:startString];
        [strM appendString:@"\n"];
        [strM appendString:myCode];
        [strM appendString:@"\n"];
        [strM appendString:endString];
        [text setString:strM];
    }
}

/**往最前面的那个@end代码块中添加函数代码*/
+ (void)addCodeToFirstEnd:(NSString *)myCode toText:(NSMutableString *)text{
    NSInteger interfaceCount=[self getCountTargetString:@"@interface" inText:text];
    if (interfaceCount==0) {
        return;
    }
    
    NSInteger endIndex=[text rangeOfString:@"@end"].location;
    if (endIndex!=NSNotFound) {
        NSString *startString=[text substringToIndex:endIndex];
        NSString *endString=[text substringFromIndex:endIndex];
        NSMutableString *strM=[NSMutableString string];
        [strM appendString:startString];
        [strM appendString:myCode];
        [strM appendString:@"\n"];
        [strM appendString:endString];
        [text setString:strM];
    }
}

/**往@implementation中添加代码*/
+ (void)addCodeToImplementation:(NSString *)myCode toText:(NSMutableString *)text{
    NSInteger implementationCount=[self getCountTargetString:@"@implementation" inText:text];
    if (implementationCount==0) {
        return;
    }
    if (implementationCount>1) {
        NSLog(@"%@",@"你的.m文件中有两个类");
    }
    
    NSInteger implementationIndex=[text rangeOfString:@"@implementation"].location;
    if(implementationCount>1){
        //这里选择后面的那个implementation为默认
        implementationIndex = [text rangeOfString:@"@implementation" options:NSBackwardsSearch|NSLiteralSearch].location;
    }
    if (implementationIndex==NSNotFound) {
        return;
    }
    NSInteger startIndex=[text rangeOfString:@"\n" options:NSLiteralSearch range:NSMakeRange(implementationIndex, text.length-implementationIndex)].location;
    if (startIndex!=NSNotFound) {
        NSString *startString=[text substringToIndex:startIndex];
        NSString *endString=[text substringFromIndex:startIndex];
        NSMutableString *strM=[NSMutableString string];
        [strM appendString:startString];
        [strM appendString:@"\n"];
        [strM appendString:myCode];
        [strM appendString:@"\n"];
        [strM appendString:endString];
        [text setString:strM];
    }
}

/**往头文件中添加代码*/
+ (void)addCodeToImport:(NSString *)myCode toText:(NSMutableString *)text{
    
    NSInteger index=[text rangeOfString:@"#import" options:NSBackwardsSearch|NSLiteralSearch].location;
    if (index!=NSNotFound) {
        NSInteger len=100;
        if (len>text.length-index-1) {
            len=text.length-index-1;
        }
        index=[text rangeOfString:@"\n" options:NSLiteralSearch range:NSMakeRange(index+1, len)].location;
        if (index!=NSNotFound) {
            NSString *startString=[text substringToIndex:index];
            NSString *endString=[text substringFromIndex:index];
            NSMutableString *strM=[NSMutableString string];
            [strM appendString:startString];
            [strM appendString:@"\n"];
            [strM appendString:myCode];
            [strM appendString:endString];
            [text setString:strM];
        }
    }else{
        NSMutableString *strM=[NSMutableString string];
        [strM appendString:[[myCode stringByAppendingString:@"\n"]stringByAppendingString:text]];
        [text setString:strM];
    }
}

/**将要添加代码替换本身函数*/
+ (void)addCodeByReplaceFunction:(NSString *)myCode WithIdentity:(NSString *)identity toText:(NSMutableString *)text{
    NSInteger start=[text rangeOfString:identity].location;
    if (start==NSNotFound) {
        return;
    }
    //找到最后一个},代表这个函数结束了
    NSInteger count=1;
    unichar ch;
    NSInteger i;
    for (i=start+identity.length+1; i<text.length; i++) {
        ch=[text characterAtIndex:i];
        if (ch=='{') {
            count++;
        }else if (ch=='}'){
            count--;
            if (count==0) {
                start=i-1;
                break;
            }
        }
    }
    if (i==text.length) {
        NSLog(@"%@",@"开关{}没对称");
    }else{
        NSString *startString=[text substringToIndex:start];
        NSString *endString=[text substringFromIndex:start];
        NSMutableString *strM=[NSMutableString string];
        [strM appendString:startString];
        [strM appendString:myCode];
        [strM appendString:@"\n"];
        [strM appendString:endString];
        [text setString:strM];
    }
}

/**找到某个函数包括函数里面的内容*/
+ (NSString *)findCodeFunctionWithIdentity:(NSString *)identity WithText:(NSMutableString *)text{
    NSInteger start=[text rangeOfString:identity].location;
    NSInteger oldStart=start;
    if (start==NSNotFound) {
        return @"";
    }
    //找到最后一个},代表这个函数结束了
    NSInteger count=1;
    unichar ch;
    NSInteger i;
    for (i=start+identity.length+1; i<text.length; i++) {
        ch=[text characterAtIndex:i];
        if (ch=='{') {
            count++;
        }else if (ch=='}'){
            count--;
            if (count==0) {
                start=i-1;
                break;
            }
        }
    }
    if (i==text.length) {
        NSLog(@"%@",@"开关{}没对称");
    }else{
        NSString *tempString=[text substringWithRange:NSMakeRange(oldStart, i-oldStart+1)];
        return tempString;
    }
    return @"";
}


#pragma mark-----------辅助函数
/**返回指定目标字符串在总字符串中的个数*/
+ (NSInteger)getCountTargetString:(NSString *)targetStr inText:(NSString *)text{
    
    NSInteger count=0;
    NSInteger indexStart=[text rangeOfString:targetStr].location;
    while (indexStart!=NSNotFound) {
        count++;
        
        indexStart+=targetStr.length;
        
        if (indexStart<text.length-1) {
            indexStart=[text rangeOfString:targetStr options:NSLiteralSearch range:NSMakeRange(indexStart, text.length-indexStart)].location;
        }else break;
    }
    return count;
}

+ (void)addDelegateTableViewToText:(NSMutableString *)text{
    [self addCodeText:@"UITableViewDelegate,UITableViewDataSource" andInsertType:ZHAddCodeType_Delegate toStrM:text insertFunction:nil];
}
+ (void)addDelegateCollectionViewToText:(NSMutableString *)text{
    [self addCodeText:@"UICollectionViewDelegateFlowLayout,UICollectionViewDataSource" andInsertType:ZHAddCodeType_Delegate toStrM:text insertFunction:nil];
}

+ (void)addDelegateFunctionToText:(NSMutableString *)text withTableViews:(NSDictionary *)tableViewsDic isOnlyTableViewOrCollectionView:(BOOL)isOnlyTableViewOrCollectionView{
    
    NSMutableArray *tableViews=[NSMutableArray array];
    for (NSString *tableView in tableViewsDic) {
        [tableViews addObject:[NSDictionary dictionaryWithObject:tableViewsDic[tableView] forKey:tableView]];
    }
    if (tableViews.count==0) {
        return;
    }
    [self addDelegateTableViewToText:text];
    
    if (tableViews.count==1) {
        
        NSString *oneTableViewName=[tableViewsDic allKeys][0];
        
        //开始添加 属性和代理
        if(isOnlyTableViewOrCollectionView&&[self hasSuffixNumber:oneTableViewName]){
            [self addCodeText:@"@property (strong, nonatomic) UITableView *tableView;" andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:@"@property (strong, nonatomic) NSMutableArray *dataArr;" andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:@"- (NSMutableArray *)dataArr{\n\
             if (!_dataArr) {\n\
             _dataArr=[NSMutableArray array];\n\
             }\n\
             return _dataArr;\n\
             }" andInsertType:ZHAddCodeType_Implementation toStrM:text insertFunction:nil];
            [self addCodeText:@"self.tableView.delegate=self;\nself.tableView.dataSource=self;\nself.tableView.tableFooterView=[UIView new];" andInsertType:ZHAddCodeType_InsertFunction toStrM:text insertFunction:@"- (void)viewDidLoad{"];
            oneTableViewName=@"";
        }else{
            NSString *oneTableViewName_new=[self upFirstCharacter:oneTableViewName];
            [self addCodeText:[NSString stringWithFormat:@"@property (strong, nonatomic) UITableView *%@;",oneTableViewName] andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"@property (strong, nonatomic) NSMutableArray *dataArr%@;",oneTableViewName_new] andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"- (NSMutableArray *)dataArr%@{\n\
                               if (!_dataArr%@) {\n\
                               _dataArr%@=[NSMutableArray array];\n\
                               }\n\
                               return _dataArr%@;\n\
                               }",oneTableViewName_new,oneTableViewName_new,oneTableViewName_new,oneTableViewName_new] andInsertType:ZHAddCodeType_Implementation toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"self.%@.delegate=self;\nself.%@.dataSource=self;",oneTableViewName,oneTableViewName] andInsertType:ZHAddCodeType_InsertFunction toStrM:text insertFunction:@"- (void)viewDidLoad{"];
        }
        
        NSMutableString *strM=[NSMutableString string];
        [strM appendFormat:@"#pragma mark - TableViewDelegate实现的方法:\n\
        - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{\n\n\
        return 1;\n\
        }\n\
        - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{\n\n\
        return self.dataArr%@.count;\n\
         }\n",[self upFirstCharacter:oneTableViewName]];
        [strM appendFormat:@"- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{\n\n\
         id modelObjct=self.dataArr%@[indexPath.row];\n",[self upFirstCharacter:oneTableViewName]];
        
        NSDictionary *tableDic=tableViews[0];
        NSArray *cells=tableDic[[tableDic allKeys][0]];
        for (NSString *cell in cells) {
            NSString *adapterCell=[ZHStroyBoardFileManager getAdapterTableViewCellName:cell];
            NSString *tempCell=[ZHStoryboardTextManager lowerFirstCharacter:adapterCell];
            [strM appendFormat:@"if ([modelObjct isKindOfClass:[%@TableViewCellModel class]]){\n\
            %@TableViewCell *%@Cell=[tableView dequeueReusableCellWithIdentifier:@\"%@TableViewCell\"];\n\
            %@TableViewCellModel *model=modelObjct;\n\
            [%@Cell refreshUI:model];\n\
            return %@Cell;\n\
             }\n",adapterCell,adapterCell,tempCell,adapterCell,adapterCell,tempCell,tempCell];
        }
        
        //注册cell
        NSMutableString *registerClassText=[NSMutableString string];
        NSString *oneTableViewNameTemp=[tableViewsDic allKeys][0];
        for (NSString *cell in cells) {
            NSString *adapterCell=[ZHStroyBoardFileManager getAdapterTableViewCellName:cell];
            if (isOnlyTableViewOrCollectionView&&[self hasSuffixNumber:oneTableViewNameTemp]) {
                [registerClassText appendFormat:@"[self.tableView registerClass:[%@TableViewCell class] forCellReuseIdentifier:@\"%@TableViewCell\"];\n",adapterCell,adapterCell];
            }else{
                [registerClassText appendFormat:@"[self.%@ registerClass:[%@TableViewCell class] forCellReuseIdentifier:@\"%@TableViewCell\"];\n",oneTableViewNameTemp,adapterCell,adapterCell];
            }
        }
        if(registerClassText.length>0)
            [self addCodeText:registerClassText andInsertType:ZHAddCodeType_InsertFunction toStrM:text insertFunction:@"- (void)viewDidLoad{"];
        
        
        [strM appendString:@"//随便给一个cell\n\
         UITableViewCell *cell=[UITableViewCell new];\n\
         return cell;\n\
         }\n"];
        [strM appendString:@"- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{\n\n\
         return 80.0f;\n\
         }\n\
         - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{\n\
         [tableView deselectRowAtIndexPath:indexPath animated:YES];\n\
         }\n"];
        
        //开始插入
        [self addCodeText:strM andInsertType:ZHAddCodeType_end_last toStrM:text insertFunction:nil];
    }
    else{
        
        NSMutableArray *allTbaleViews=[NSMutableArray array];
        
        NSMutableDictionary *allTableViewDicM=[NSMutableDictionary dictionary];
        for (NSDictionary *tableDic in tableViews) {
            [allTbaleViews addObject:[tableDic allKeys][0]];
            [allTableViewDicM setValue:tableDic[[tableDic allKeys][0]] forKey:[tableDic allKeys][0]];
        }
        
        for (NSString *oneTableViewName in allTbaleViews) {
            NSString *oneTableViewName_new=[self upFirstCharacter:oneTableViewName];
            //开始添加 属性和代理
            [self addCodeText:[NSString stringWithFormat:@"@property (strong, nonatomic) UITableView *%@;",oneTableViewName] andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"@property (strong, nonatomic) NSMutableArray *dataArr%@;",oneTableViewName_new] andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"- (NSMutableArray *)dataArr%@{\n\
                               if (!_dataArr%@) {\n\
                               _dataArr%@=[NSMutableArray array];\n\
                               }\n\
                               return _dataArr%@;\n\
                               }",oneTableViewName_new,oneTableViewName_new,oneTableViewName_new,oneTableViewName_new] andInsertType:ZHAddCodeType_Implementation toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"self.%@.delegate=self;\nself.%@.dataSource=self;",oneTableViewName,oneTableViewName] andInsertType:ZHAddCodeType_InsertFunction toStrM:text insertFunction:@"- (void)viewDidLoad{"];
        }
        
        //注册cell
        NSMutableString *registerClassText=[NSMutableString string];
        
        for (NSInteger i=0; i<allTbaleViews.count; i++) {
            NSString *tableView=allTbaleViews[i];
            NSArray *cells=allTableViewDicM[tableView];
            for (NSString *cell in cells) {
                NSString *adapterCell=[ZHStroyBoardFileManager getAdapterTableViewCellName:cell];
                [registerClassText appendFormat:@"[self.%@ registerClass:[%@TableViewCell class] forCellReuseIdentifier:@\"%@TableViewCell\"];\n",tableView,adapterCell,adapterCell];
            }
        }
        if(registerClassText.length>0)
            [self addCodeText:registerClassText andInsertType:ZHAddCodeType_InsertFunction toStrM:text insertFunction:@"- (void)viewDidLoad{"];
        
        NSMutableString *strM=[NSMutableString string];
        [strM appendString:@"#pragma mark - TableViewDelegate实现的方法:\n\
         - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{\n\n"];
        
        for (NSInteger i=0; i<allTbaleViews.count; i++) {
            NSString *tableView=allTbaleViews[i];
            if (i==0) {
                [strM appendFormat:@"if ([tableView isEqual:self.%@]) {\n\
                 return 1;\n\
                 }",tableView];
            }else{
                [strM appendFormat:@"else if ([tableView isEqual:self.%@]){\n\
                 return 1;\n\
                 }",tableView];
            }
        }
        [strM appendString:@"\n"];
        [strM appendFormat:@"	return 1;\n\
         }\n"];
        [strM appendString:@"- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{\n\n"];
        for (NSInteger i=0; i<allTbaleViews.count; i++) {
            NSString *tableView=allTbaleViews[i];
            if (i==0) {
                [strM appendFormat:@"if ([tableView isEqual:self.%@]) {\n\
                 return self.dataArr%@.count;\n\
                 }",tableView,[self upFirstCharacter:tableView]];
            }else{
                [strM appendFormat:@"else if ([tableView isEqual:self.%@]){\n\
                 return self.dataArr%@.count;\n\
                 }",tableView,[self upFirstCharacter:tableView]];
            }
        }
        [strM appendString:@"\n"];
        [strM appendFormat:@"	return 0;\n\
         }\n"];
        [strM appendString:@"- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{\n\n"];
        for (NSInteger i=0; i<allTbaleViews.count; i++) {
            NSString *tableView=allTbaleViews[i];
            if (i==0) {
                [strM appendFormat:@"if ([tableView isEqual:self.%@]) {\n",tableView];
            }else{
                [strM appendFormat:@"else if ([tableView isEqual:self.%@]){\n",tableView];
            }
            [strM appendFormat:@"id modelObjct=self.dataArr%@[indexPath.row];\n",[self upFirstCharacter:tableView]];
            NSArray *cells=allTableViewDicM[tableView];
            for (NSString *cell in cells) {
                NSString *adapterCell=[ZHStroyBoardFileManager getAdapterTableViewCellName:cell];
                NSString *tempCell=[ZHStoryboardTextManager lowerFirstCharacter:adapterCell];
                [strM appendFormat:@"if ([modelObjct isKindOfClass:[%@TableViewCellModel class]]){\n\
                 %@TableViewCell *%@Cell=[tableView dequeueReusableCellWithIdentifier:@\"%@TableViewCell\"];\n\
                 %@TableViewCellModel *model=modelObjct;\n\
                 [%@Cell refreshUI:model];\n\
                 return %@Cell;\n\
                 }\n",adapterCell,adapterCell,tempCell,adapterCell,adapterCell,tempCell,tempCell];
            }
            [strM appendString:@"}\n"];
        }
        [strM appendString:@"//随便给一个cell\n\
         UITableViewCell *cell=[UITableViewCell new];\n\
         return cell;\n}\n"];
        
        [strM appendString:@"- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{\n\n"];
        for (NSInteger i=0; i<allTbaleViews.count; i++) {
            NSString *tableView=allTbaleViews[i];
            if (i==0) {
                [strM appendFormat:@"if ([tableView isEqual:self.%@]) {\n",tableView];
            }else{
                [strM appendFormat:@"else if ([tableView isEqual:self.%@]){\n",tableView];
            }
            [strM appendFormat:@"id modelObjct=self.dataArr%@[indexPath.row];\n",[self upFirstCharacter:tableView]];
            NSArray *cells=allTableViewDicM[tableView];
            for (NSString *cell in cells) {
                NSString *adapterCell=[ZHStroyBoardFileManager getAdapterTableViewCellName:cell];
                [strM appendFormat:@"if ([modelObjct isKindOfClass:[%@TableViewCellModel class]]){\n\
                 return 80.0f;\n\
                 }\n",adapterCell];
            }
            [strM appendString:@"}\n"];
            
        }
        [strM appendString:@"	return 80.0f;\n\
         }\n"];
        [strM appendString:@"- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{\n\n\
         [tableView deselectRowAtIndexPath:indexPath animated:YES];\n"];
        for (NSInteger i=0; i<allTbaleViews.count; i++) {
            NSString *tableView=allTbaleViews[i];
            if (i==0) {
                [strM appendFormat:@"if ([tableView isEqual:self.%@]) {\n",tableView];
            }else{
                [strM appendFormat:@"else if ([tableView isEqual:self.%@]){\n",tableView];
            }
            [strM appendFormat:@"id modelObjct=self.dataArr%@[indexPath.row];\n",[self upFirstCharacter:tableView]];
            NSArray *cells=allTableViewDicM[tableView];
            for (NSString *cell in cells) {
                NSString *adapterCell=[ZHStroyBoardFileManager getAdapterTableViewCellName:cell];
                [strM appendFormat:@"if ([modelObjct isKindOfClass:[%@TableViewCellModel class]]){\n\n\
                 }",adapterCell];
            }
            [strM appendString:@"\n}\n"];
        }
        [strM appendString:@"}\n"];
        //开始插入
        [self addCodeText:strM andInsertType:ZHAddCodeType_end_last toStrM:text insertFunction:nil];
    }
    
}
+ (void)addDelegateFunctionToText:(NSMutableString *)text withCollectionViews:(NSDictionary *)collectionViewsDic isOnlyTableViewOrCollectionView:(BOOL)isOnlyTableViewOrCollectionView{
    
    NSMutableArray *collectionViews=[NSMutableArray array];
    for (NSString *collectionView in collectionViewsDic) {
        [collectionViews addObject:[NSDictionary dictionaryWithObject:collectionViewsDic[collectionView] forKey:collectionView]];
    }
    if (collectionViews.count==0) {
        return;
    }
    [self addDelegateCollectionViewToText:text];
    
    
//    [self addCodeText:@"/**为collectionView添加布局*/\n\
//     - (void)addFlowLayoutToCollectionView:(UICollectionView *)collectionView{\n\
//     UICollectionViewFlowLayout *flow = [UICollectionViewFlowLayout new];\n\
//     \n\
//     flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;//水平\n\
//     //    flow.scrollDirection = UICollectionViewScrollDirectionVertical;//垂直\n\
//     \n\
//     flow.minimumInteritemSpacing = 10;\n\
//     flow.minimumLineSpacing = 10;\n\
//     collectionView.collectionViewLayout=flow;\n\
//     \n\
//     collectionView.backgroundColor=[UIColor whiteColor];//背景颜色\n\
//     \n\
//     collectionView.contentInset=UIEdgeInsetsMake(10, 10, 10, 10);//内嵌值\n\
//     }\n" andInsertType:ZHAddCodeType_end_last toStrM:text insertFunction:nil];
    
    if (collectionViews.count==1) {
        
        NSString *oneCollectionViewName=[collectionViewsDic allKeys][0];
        
        //开始添加 属性和代理
        if(isOnlyTableViewOrCollectionView&&[self hasSuffixNumber:oneCollectionViewName]){
            [self addCodeText:@"@property (strong, nonatomic) UICollectionView *collectionView;" andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:@"@property (strong, nonatomic) NSMutableArray *dataArr;" andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:@"- (NSMutableArray *)dataArr{\n\
             if (!_dataArr) {\n\
             _dataArr=[NSMutableArray array];\n\
             }\n\
             return _dataArr;\n\
             }" andInsertType:ZHAddCodeType_Implementation toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"self.collectionView.delegate=self;\nself.collectionView.dataSource=self;"] andInsertType:ZHAddCodeType_InsertFunction toStrM:text insertFunction:@"- (void)viewDidLoad{"];
            oneCollectionViewName=@"";
            
        }else{
            NSString *oneCollectionViewName_new=[self upFirstCharacter:oneCollectionViewName];
            [self addCodeText:[NSString stringWithFormat:@"@property (strong, nonatomic) UICollectionView *%@;",oneCollectionViewName] andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"@property (strong, nonatomic) NSMutableArray *dataArr%@;",oneCollectionViewName_new] andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"- (NSMutableArray *)dataArr%@{\n\
                               if (!_dataArr%@) {\n\
                               _dataArr%@=[NSMutableArray array];\n\
                               }\n\
                               return _dataArr%@;\n\
                               }",oneCollectionViewName_new,oneCollectionViewName_new,oneCollectionViewName_new,oneCollectionViewName_new] andInsertType:ZHAddCodeType_Implementation toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"self.%@.delegate=self;\nself.%@.dataSource=self;",oneCollectionViewName,oneCollectionViewName] andInsertType:ZHAddCodeType_InsertFunction toStrM:text insertFunction:@"- (void)viewDidLoad{"];
        }
        
        NSMutableString *strM=[NSMutableString string];
        [strM appendFormat:@"#pragma mark - collectionView的代理方法:\n\
         // 1.返回组数:\n\
         - (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView\n\
         {\n\
         return 1;\n\
         }\n\
         // 2.返回每一组item的个数:\n\
         - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section\n\
         {\n\
         return self.dataArr%@.count;\n\
         }\n",[self upFirstCharacter:oneCollectionViewName]];
        
        [strM appendFormat:@"// 3.返回每一个item（cell）对象;\n\
         - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath\n\
         {\n\
         id modelObjct=self.dataArr%@[indexPath.row];\n",[self upFirstCharacter:oneCollectionViewName]];
        
        NSDictionary *collectionDic=collectionViews[0];
        NSArray *cells=collectionDic[[collectionDic allKeys][0]];
        
        
        for (NSString *cell in cells) {
            NSString *adapterCell=[ZHStroyBoardFileManager getAdapterCollectionViewCellName:cell];
            NSString *tempCell=[ZHStoryboardTextManager lowerFirstCharacter:adapterCell];
            [strM appendFormat:@"if ([modelObjct isKindOfClass:[%@CollectionViewCellModel class]]) {\n\
             %@CollectionViewCell *%@Cell=[collectionView dequeueReusableCellWithReuseIdentifier:@\"%@CollectionViewCell\" forIndexPath:indexPath];\n\
             %@CollectionViewCellModel *model=modelObjct;\n\
             [%@Cell refreshUI:model];\n\
             return %@Cell;\n\
             }\n",adapterCell,adapterCell,tempCell,adapterCell,adapterCell,tempCell,tempCell];
        }
        
        
        //注册cell
        NSMutableString *registerClassText=[NSMutableString string];
        NSString *oneCollectionViewNameTemp=[collectionViewsDic allKeys][0];
        for (NSString *cell in cells) {
            NSString *adapterCell=[ZHStroyBoardFileManager getAdapterCollectionViewCellName:cell];
            if (isOnlyTableViewOrCollectionView&&[self hasSuffixNumber:oneCollectionViewNameTemp]) {
                [registerClassText appendFormat:@"[self.collectionView registerClass:[%@CollectionViewCell class] forCellWithReuseIdentifier:@\"%@CollectionViewCell\"];\n",adapterCell,adapterCell];
            }else{
                [registerClassText appendFormat:@"[self.%@ registerClass:[%@CollectionViewCell class] forCellWithReuseIdentifier:@\"%@CollectionViewCell\"];\n",oneCollectionViewNameTemp,adapterCell,adapterCell];
            }
        }
        
        if(registerClassText.length>0)
            [self addCodeText:registerClassText andInsertType:ZHAddCodeType_InsertFunction toStrM:text insertFunction:@"- (void)viewDidLoad{"];
        
        [strM appendString:@"    //随便给一个cell\n\
         UICollectionViewCell *cell=[UICollectionViewCell new];\n\
         return cell;\n\
         }\n"];
        [strM appendString:@"//4.每一个item的大小:\n\
         - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath\n\
         {\n\
         return CGSizeMake(100, 100);\n\
         }\n\
         // 5.选择某一个cell:\n\
         - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath\n\
         {\n\
         [collectionView deselectItemAtIndexPath:indexPath animated:YES];\n\
         }\n"];
        
        //开始插入
        [self addCodeText:strM andInsertType:ZHAddCodeType_end_last toStrM:text insertFunction:nil];
    }else{
        
        NSMutableArray *allCollectionViews=[NSMutableArray array];
        
        NSMutableDictionary *allCollectionViewDicM=[NSMutableDictionary dictionary];
        for (NSDictionary *collectionDic in collectionViews) {
            [allCollectionViews addObject:[collectionDic allKeys][0]];
            [allCollectionViewDicM setValue:collectionDic[[collectionDic allKeys][0]] forKey:[collectionDic allKeys][0]];
        }
        
        //注册cell
        NSMutableString *registerClassText=[NSMutableString string];
        for (NSInteger i=0; i<allCollectionViews.count; i++) {
            NSString *collectionView=allCollectionViews[i];
            NSArray *cells=allCollectionViewDicM[collectionView];
            for (NSString *cell in cells) {
                NSString *adapterCell=[ZHStroyBoardFileManager getAdapterCollectionViewCellName:cell];
                [registerClassText appendFormat:@"[self.%@ registerClass:[%@CollectionViewCell class] forCellWithReuseIdentifier:@\"%@CollectionViewCell\"];\n",collectionView,adapterCell,adapterCell];
            }
        }
        if(registerClassText.length>0)
            [self addCodeText:registerClassText andInsertType:ZHAddCodeType_InsertFunction toStrM:text insertFunction:@"- (void)viewDidLoad{"];
        
        for (NSString *oneCollectionViewName in allCollectionViews) {
            NSString *oneTableViewName_new=[self upFirstCharacter:oneCollectionViewName];
            //开始添加 属性和代理
            [self addCodeText:[NSString stringWithFormat:@"@property (strong, nonatomic) UICollectionView *%@;",oneCollectionViewName] andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"@property (strong, nonatomic) NSMutableArray *dataArr%@;",oneTableViewName_new] andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"- (NSMutableArray *)dataArr%@{\n\
                               if (!_dataArr%@) {\n\
                               _dataArr%@=[NSMutableArray array];\n\
                               }\n\
                               return _dataArr%@;\n\
                               }",oneTableViewName_new,oneTableViewName_new,oneTableViewName_new,oneTableViewName_new] andInsertType:ZHAddCodeType_Implementation toStrM:text insertFunction:nil];
            [self addCodeText:[NSString stringWithFormat:@"self.%@.delegate=self;\nself.%@.dataSource=self;",oneCollectionViewName,oneCollectionViewName] andInsertType:ZHAddCodeType_InsertFunction toStrM:text insertFunction:@"- (void)viewDidLoad{"];
        }
        
        NSMutableString *strM=[NSMutableString string];
        [strM appendString:@"#pragma mark - collectionView的代理方法:\n\
         // 1.返回组数:\n\
         - (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView\n\
         {\n\n"];
        
        for (NSInteger i=0; i<allCollectionViews.count; i++) {
            NSString *collectionView=allCollectionViews[i];
            if (i==0) {
                [strM appendFormat:@"if ([collectionView isEqual:self.%@]) {\n\
                 return 1;\n\
                 }",collectionView];
            }else{
                [strM appendFormat:@"else if([collectionView isEqual:self.%@]){\n\
                 return 1;\n\
                 }",collectionView];
            }
        }
        [strM appendString:@"\n"];
        [strM appendFormat:@"	return 1;\n\
         }\n"];
        [strM appendString:@"// 2.返回每一组item的个数:\n\
         - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section\n\
         {\n\n"];
        for (NSInteger i=0; i<allCollectionViews.count; i++) {
            NSString *collectionView=allCollectionViews[i];
            if (i==0) {
                [strM appendFormat:@"if ([collectionView isEqual:self.%@]) {\n\
                 return self.dataArr%@.count;\n\
                 }",collectionView,[self upFirstCharacter:collectionView]];
            }else{
                [strM appendFormat:@"else if([collectionView isEqual:self.%@]){\n\
                 return self.dataArr%@.count;\n\
                 }",collectionView,[self upFirstCharacter:collectionView]];
            }
        }
        [strM appendString:@"\n"];
        [strM appendFormat:@"	return 0;\n\
         }\n"];
        [strM appendString:@"// 3.返回每一个item（cell）对象;\n\
         - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath\n\
         {\n\n"];
        for (NSInteger i=0; i<allCollectionViews.count; i++) {
            NSString *collectionView=allCollectionViews[i];
            if (i==0) {
                [strM appendFormat:@"if ([collectionView isEqual:self.%@]) {\n",collectionView];
            }else{
                [strM appendFormat:@"else if ([collectionView isEqual:self.%@]){\n",collectionView];
            }
            [strM appendFormat:@"id modelObjct=self.dataArr%@[indexPath.row];\n",[self upFirstCharacter:collectionView]];
            NSArray *cells=allCollectionViewDicM[collectionView];
            for (NSString *cell in cells) {
                NSString *adapterCell=[ZHStroyBoardFileManager getAdapterCollectionViewCellName:cell];
                NSString *tempCell=[ZHStoryboardTextManager lowerFirstCharacter:adapterCell];
                [strM appendFormat:@"if ([modelObjct isKindOfClass:[%@CollectionViewCellModel class]]) {\n\
                 %@CollectionViewCell *%@Cell=[collectionView dequeueReusableCellWithReuseIdentifier:@\"%@CollectionViewCell\" forIndexPath:indexPath];\n\
                 %@CollectionViewCellModel *model=modelObjct;\n\
                 [%@Cell refreshUI:model];\n\
                 return %@Cell;\n\
                 }\n",adapterCell,adapterCell,tempCell,adapterCell,adapterCell,tempCell,tempCell];
            }
            [strM appendString:@"}\n"];
        }
        [strM appendString:@"//随便给一个cell\n\
         UICollectionViewCell *cell=[UICollectionViewCell new];\n\
         return cell;\n\
         }\n"];
        
        [strM appendString:@"//4.每一个item的大小:\n\
         - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath\n\
         {\n\n"];
        for (NSInteger i=0; i<allCollectionViews.count; i++) {
            NSString *collectionView=allCollectionViews[i];
            if (i==0) {
                [strM appendFormat:@"if ([collectionView isEqual:self.%@]) {\n",collectionView];
            }else{
                [strM appendFormat:@"else if ([collectionView isEqual:self.%@]){\n",collectionView];
            }
            [strM appendFormat:@"id modelObjct=self.dataArr%@[indexPath.row];\n",[self upFirstCharacter:collectionView]];
            NSArray *cells=allCollectionViewDicM[collectionView];
            for (NSString *cell in cells) {
                NSString *adapterCell=[ZHStroyBoardFileManager getAdapterCollectionViewCellName:cell];
                [strM appendFormat:@"if ([modelObjct isKindOfClass:[%@CollectionViewCellModel class]]){\n\
                 return CGSizeMake(100, 100);\n\
                 }\n",adapterCell];
            }
            [strM appendString:@"}\n"];
            
        }
        [strM appendString:@"	return CGSizeMake(100, 100);\n\
         }\n"];
        [strM appendString:@"// 5.选择某一个cell:\n\
         - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath\n\
         {\n\
         [collectionView deselectItemAtIndexPath:indexPath animated:YES];\n"];
        for (NSInteger i=0; i<allCollectionViews.count; i++) {
            NSString *collectionView=allCollectionViews[i];
            if (i==0) {
                [strM appendFormat:@"if ([collectionView isEqual:self.%@]) {\n",collectionView];
            }else{
                [strM appendFormat:@"else if ([collectionView isEqual:self.%@]){\n",collectionView];
            }
            [strM appendFormat:@"id modelObjct=self.dataArr%@[indexPath.row];\n",[self upFirstCharacter:collectionView]];
            NSArray *cells=allCollectionViewDicM[collectionView];
            for (NSString *cell in cells) {
                NSString *adapterCell=[ZHStroyBoardFileManager getAdapterCollectionViewCellName:cell];
                [strM appendFormat:@"if ([modelObjct isKindOfClass:[%@CollectionViewCellModel class]]){\n\n\
                 }",adapterCell];
            }
            [strM appendString:@"\n}\n"];
        }
        [strM appendString:@"}\n"];
        //开始插入
        [self addCodeText:strM andInsertType:ZHAddCodeType_end_last toStrM:text insertFunction:nil];
    }
}

+ (NSString *)checkRelation:(NSString *)relation reverse:(BOOL)reverse
{
    NSString *relationStr = @"";
    if ([relation isEqualToString:@"greaterThanOrEqual"]) {
        relationStr = @"greaterThanOrEqualTo";
        if (reverse) {
            relationStr = @"lessThanOrEqualTo";
        }
    }else if ([relation isEqualToString:@"lessThanOrEqual"]){
        relationStr = @"lessThanOrEqualTo";
        if (reverse) {
            relationStr = @"greaterThanOrEqualTo";
        }
    }
    
    return relationStr;
}
/**创建约束代码*/
+ (NSString *)get1CreatConstraintCodeWithIdStr:(NSString *)idStr WithViewName:(NSString *)viewName withConstraintDic:(NSDictionary *)constraintDic withSelfConstraintDic:(NSDictionary *)selfConstraintDic withOutletView:(NSDictionary *)outletView isCell:(BOOL)isCell withCustomAndNameDic:(NSDictionary *)customAndNameDic addToFatherView:(NSString *)fatherView isOnlyTableViewOrCollectionView:(BOOL)isOnlyTableViewOrCollectionView withIdAndOutletViewsDic:(NSDictionary *)idAndOutletViews{
    
    NSMutableString *textCode=[NSMutableString string];
    BOOL hasFDCheck  = NO;
    
    [textCode appendFormat:@"[self.%@ mas_makeConstraints:^(MASConstraintMaker *make) {\n",viewName];
    
    NSArray *constraintArr=constraintDic[viewName];
    if (constraintArr.count>0) {
        for (NSDictionary *constraintSubDic in constraintArr) {
            
            //            NSLog(@"%@:%@",viewName,constraintSubDic);
            
            //每一个具体的约束
            
            NSString *firstAttribute=constraintSubDic[@"firstAttribute"];
            NSString *firstItem=constraintSubDic[@"firstItem"];
            NSString *secondAttribute=constraintSubDic[@"secondAttribute"];
            NSString *secondItem=constraintSubDic[@"secondItem"];
            NSString *multiplier=constraintSubDic[@"multiplier"];
            NSString *constant=constraintSubDic[@"constant"];
            NSString *idStr=constraintSubDic[@"id"];
            NSString *relation = @"";
            if ([constraintSubDic containsObjectForKey:@"relation"]) {
                relation = [constraintSubDic objectForKey:@"relation"];
            }
            NSString *priority = @"";
            if ([constraintSubDic containsObjectForKey:@"priority"]) {
                priority = [constraintSubDic objectForKey:@"priority"];
            }
            
            NSString *isFd = @"";
            NSString *checkoutProperty = [NSString stringWithFormat:@"isShow%@",[ZHNSString upFirstCharacter:viewName]];
            if ([constraintSubDic containsObjectForKey:@"isFD"]) {
                isFd = [constraintSubDic objectForKey:@"isFD"];
                // isShowRecommend?34:0
                constant = [NSString stringWithFormat:@"%@?%@:0",checkoutProperty,constant];
                if (!hasFDCheck) {
                    hasFDCheck = YES;
                    //BOOL isShowRecommend = (self.cellEntity.recommendReason.length > 0);
                    NSString *checkStr = [NSString stringWithFormat:@"BOOL %@ = (self.<#viewModel#>.<#对应属性#>.length > 0);\n",checkoutProperty];
                    [textCode replaceOccurrencesOfString:@"mas_makeConstraints" withString:@"mas_remakeConstraints" options:(NSLiteralSearch) range:NSMakeRange(0, textCode.length)];
                    textCode = [NSMutableString stringWithFormat:@"%@%@",checkStr,textCode];
                }
            }
            
            if ([firstItem hasPrefix:@"self.view"]) {
                firstItem=@"self.view";
            }
            if ([secondItem hasPrefix:@"self.view"]) {
                secondItem=@"self.view";
            }
            
            if ([firstItem hasSuffix:@"CollectionViewCell"]||[firstItem hasSuffix:@"TableViewCell"]) {
                firstItem=@"self.contentView";
            }
            if ([secondItem hasSuffix:@"CollectionViewCell"]||[secondItem hasSuffix:@"TableViewCell"]) {
                secondItem=@"self.contentView";
            }
            
            if([self isSystemIdStr:firstItem]){
                if (isCell) {
                    firstItem=@"self.contentView";
                }else{
                    firstItem=fatherView;
                }
            }
            
            if([self isSystemIdStr:secondItem]){
                if (isCell) {
                    secondItem=@"self.contentView";
                }else{
                    secondItem=fatherView;
                }
            }
            
            //1.如果该约束的第一对象是自己
            if ([firstItem isEqualToString:viewName]) {
                
                if (secondItem.length>0) {//第2对象存在
                    
                    if(secondAttribute.length>0){
                        if ([secondItem hasPrefix:@"self."]) {
                            if(constant.length>0){
                                if ([firstAttribute isEqualToString:@"trailing"]||[firstAttribute isEqualToString:@"bottom"]) {
                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                NSString *action = @"equalTo";
                                if (relation.length > 0) {
                                    action = relation;
                                }
                                [textCode appendFormat:@"make.%@.%@(%@.mas_%@).with.offset(%@)",firstAttribute,action,secondItem,firstAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",firstAttribute,secondItem,firstAttribute];
                            }
                        }else{
                            if(constant.length>0){
                                if (([firstAttribute isEqualToString:@"trailing"]||[firstAttribute isEqualToString:@"bottom"])&&[firstAttribute isEqualToString:secondAttribute]) {
                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                NSString *action = @"equalTo";
                                if (relation.length > 0) {
                                    action = relation;
                                }
                                [textCode appendFormat:@"make.%@.%@(self.%@.mas_%@).with.offset(%@)",firstAttribute,action,secondItem,secondAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(self.%@.mas_%@)",firstAttribute,secondItem,secondAttribute];
                            }
                        }
                        
                    }else{
                        NSLog(@"%@",@"约束很奇怪  有secondItem 没有 secondAttribute");
                    }
                    
                }else{//第2对象不存在
                    if(constant.length>0){
                        [textCode appendFormat:@"make.%@.equalTo(@(%@))",firstAttribute,constant];
                    }else{
                        NSLog(@"%@",@"约束很奇怪  宽高没有值");
                    }
                }
                
            }
            else if ([secondItem isEqualToString:viewName]){
                
                if (firstItem.length>0&&[self isSystemIdStr:firstItem]==NO) {
                    if(firstAttribute.length>0){
                        
                        if ([firstItem hasPrefix:@"self."]) {
                            if(constant.length>0){
                                if ([secondAttribute isEqualToString:@"trailing"]||[secondAttribute hasPrefix:@"bottom"]) {
                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                NSString *action = @"equalTo";
                                if (relation.length > 0) {
                                    action = relation;
                                }
                                [textCode appendFormat:@"make.%@.%@(%@.mas_%@).with.offset(%@)",secondAttribute,action,firstItem,secondAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",secondAttribute,firstItem,secondAttribute];
                            }
                        }else{
                            if(constant.length>0){
                                if (([firstAttribute isEqualToString:@"trailing"]||[firstAttribute isEqualToString:@"bottom"])&&[firstAttribute isEqualToString:secondAttribute]) {
                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                NSString *action = @"equalTo";
                                if (relation.length > 0) {
                                    action = relation;
                                }
                                [textCode appendFormat:@"make.%@.%@(self.%@.mas_%@).with.offset(%@)",secondAttribute,action,firstItem,firstAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(self.%@.mas_%@)",secondAttribute,firstItem,firstAttribute];
                            }
                        }
                        
                    }else{
                        NSLog(@"%@",@"约束很奇怪  有firstItem 没有 firstAttribute");
                    }
                }else{
                    if (selfConstraintDic[viewName]!=nil) {
                        BOOL isSelfConstraint=NO;
                        for (NSDictionary *dicTemp in selfConstraintDic[viewName]) {
                            if([dicTemp[@"id"] isEqualToString:idStr]){
                                isSelfConstraint=YES;
                                break;
                            }
                        }
                        if (isSelfConstraint==YES) {
                            if (firstItem.length<=0) {
                                if (isCell) {
                                    firstItem=viewName;
                                }else{
                                    firstItem=fatherView;
                                }
                            }
                            if(constant.length>0){
                                if ([secondAttribute isEqualToString:@"trailing"]||[secondAttribute hasPrefix:@"bottom"]) {
                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                NSString *action = @"equalTo";
                                if (relation.length > 0) {
                                    action = relation;
                                }
                                [textCode appendFormat:@"make.%@.%@(%@.mas_%@).with.offset(%@)",secondAttribute,action,firstItem,firstAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",secondAttribute,firstItem,firstAttribute];
                            }
                        }else{
                            if (firstItem.length<=0) {
                                if (firstAttribute.length>0&&secondAttribute.length>0) {
                                    firstItem=fatherView;
                                }else{
                                    if (isCell) {
                                        firstItem=@"self.contentView";
                                    }else{
                                        firstItem=@"self.view";
                                    }
                                }
                            }
                            if(constant.length>0){
                                if ([secondAttribute isEqualToString:@"trailing"]||[secondAttribute hasPrefix:@"bottom"]) {
                                    relation = [self checkRelation:relation reverse:YES];
                                    constant=[@"-" stringByAppendingString:constant];
                                }
                                NSString *action = @"equalTo";
                                if (relation.length > 0) {
                                    action = relation;
                                }
                                [textCode appendFormat:@"make.%@.%@(%@.mas_%@).with.offset(%@)",secondAttribute,action,firstItem,secondAttribute,constant];
                            }else{
                                [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",secondAttribute,firstItem,secondAttribute];
                            }
                        }
                    }else{
                        if (firstItem.length<=0) {
                            if (firstAttribute.length>0&&secondAttribute.length>0) {
                                firstItem=fatherView;
                            }else{
                                if (isCell) {
                                    firstItem=@"self.contentView";
                                }else{
                                    firstItem=@"self.view";
                                }
                            }
                        }
                        if(constant.length>0){
                            if ([secondAttribute isEqualToString:@"trailing"]||[secondAttribute hasPrefix:@"bottom"]) {
                                relation = [self checkRelation:relation reverse:YES];
                                constant=[@"-" stringByAppendingString:constant];
                            }
                            NSString *action = @"equalTo";
                            if (relation.length > 0) {
                                action = relation;
                            }
                            [textCode appendFormat:@"make.%@.%@(%@.mas_%@).with.offset(%@)",secondAttribute,action,firstItem,secondAttribute,constant];
                        }else{
                            [textCode appendFormat:@"make.%@.equalTo(%@.mas_%@)",secondAttribute,firstItem,secondAttribute];
                        }
                    }
                }
                
            }
            else{
                if (firstAttribute.length>0) {
                    [textCode appendFormat:@"make.%@.equalTo(@(%@))",firstAttribute,constant];
                }else{
                    NSLog(@"%@",@"约束很奇怪  没有firstAttribute");
                }
            }
            if(multiplier.length>0&&[multiplier isEqualToString:@"1"]==NO){
                [textCode appendFormat:@".multipliedBy(%@)",multiplier];
            }
            
            if (priority.length > 0) {
                [textCode appendFormat:@".priority(%@)",priority];
            }
            [textCode appendString:@";\n"];
        }
    }
    
    
    [textCode appendString:@"}];\n\n"];
    
    //解决multipliedBy(m:n)的问题
    [self dealWith_multipliedBy:textCode];
    //解决.offset(--n)的问题
    [self dealWith_offset:textCode];
    return textCode;
}

//**获取创建某个view的代码*/
+ (NSString *)getCreateViewGetterCodeWithIdStr:(NSString *)idStr WithViewName:(NSString *)viewName withViewCategoryName:(NSString *)viewCategoryName withOutletView:(NSDictionary *)outletView addToFatherView:(NSString *)fatherView isOnlyTableViewOrCollectionView:(BOOL)isOnlyTableViewOrCollectionView withIdAndOutletViewsDic:(NSDictionary *)idAndOutletViews{
    
    NSMutableString *textCode=[NSMutableString string];
    
    if ([viewName hasPrefix:@"self."]) {
        return @"";
    }
    if ([viewCategoryName isEqualToString:@"UIButton"]) {
        [textCode appendFormat:@"- (UIButton *)%@{\n",viewName];
        [textCode appendFormat:@"if (!_%@){\n",viewName];
        [textCode appendFormat:@"_%@=[UIButton buttonWithType:(UIButtonTypeCustom)];\n",viewName];
    }else if([viewCategoryName isEqualToString:@"UITableView"]){
        [textCode appendFormat:@"- (UITableView *)%@{\n",viewName];
        [textCode appendFormat:@"if (!_%@){\n",viewName];
        [textCode appendFormat:@"_%@=[[UITableView alloc]initWithFrame:CGRectZero style:(UITableViewStylePlain)];\n",viewName];
    }else if([viewCategoryName isEqualToString:@"UICollectionView"]){
        [textCode appendFormat:@"- (UICollectionView *)%@{\n",viewName];
        [textCode appendFormat:@"if (!_%@){\n",viewName];
        [textCode appendFormat:@"UICollectionViewFlowLayout *flow%@ = [UICollectionViewFlowLayout new];\n",[self upFirstCharacter:viewName]];
        [textCode appendFormat:@"//flow%@.scrollDirection = UICollectionViewScrollDirectionHorizontal;//水平\n\
         flow%@.scrollDirection = UICollectionViewScrollDirectionVertical;//垂直\n\
         flow%@.minimumInteritemSpacing = 0;\n\
         flow%@.minimumLineSpacing = 0;\n\n",[self upFirstCharacter:viewName],[self upFirstCharacter:viewName],[self upFirstCharacter:viewName],[self upFirstCharacter:viewName]];
        [textCode appendFormat:@"_%@=[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flow%@];\n",viewName,[self upFirstCharacter:viewName]];
        [textCode appendFormat:@"%@.backgroundColor=[UIColor whiteColor];\n\
         //%@.contentInset=UIEdgeInsetsMake(10, 10, 10, 10);\n",viewName,viewName];
    }else{
        [textCode appendFormat:@"- (%@ *)%@{\n",viewCategoryName,viewName];
        [textCode appendFormat:@"if (!_%@){\n",viewName];
        [textCode appendFormat:@"_%@=[%@ new];\n",viewName,viewCategoryName];
    }
    
    return textCode;
}
@end
