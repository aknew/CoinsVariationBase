//
//  iOSHelper.cpp
//  CoinsBases
//
//  Created by Alexander Kazansky on 01/05/2017.
//
//

#include "iOSHelper.h"
#include "DocViewController.h"
#include <QString>
#import <UIKit/UIDocumentInteractionController.h>


// from https://bugreports.qt.io/browse/QTBUG-42942?focusedCommentId=285903&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-285903
bool iosLaunchFile(QString strFilePath)
{
    NSString* url = strFilePath.toNSString();
    NSLog(@"%@",url);
    NSURL* fileURL = [NSURL fileURLWithPath:url];
    static DocViewController* mtv = nil;
    if(mtv!=nil)
    {
        [mtv removeFromParentViewController];
        [mtv release];
    }
    
    UIDocumentInteractionController* documentInteractionController = nil;
    documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    
    UIViewController* rootv = [[[[UIApplication sharedApplication]windows] firstObject]rootViewController];
    if(rootv!=nil)
    {
        mtv = [[DocViewController alloc] init];
        [rootv addChildViewController:mtv];
        documentInteractionController.delegate = mtv;
        [documentInteractionController presentPreviewAnimated:NO];
        return true;
    }
    return false;
}
