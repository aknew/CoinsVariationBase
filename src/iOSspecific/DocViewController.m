//
//  DocViewController.m
//  CoinsBases
//
//  Created by Alexander Kazansky on 30/04/2017.
//
//

#import "DocViewController.h"
@interface DocViewController ()
@end
@implementation DocViewController
#pragma mark -
#pragma mark View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark -
#pragma mark Document Interaction Controller Delegate Methods
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    //return [[[[UIApplication sharedApplication]windows] firstObject]rootViewController];
    return self;
}
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    [self removeFromParentViewController];
}
@end
