//
//  wslwallpaperViewController.m
//  壁纸
//
//  Created by qianfeng on 15/10/10.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "wslwallpaperViewController.h"
#import "wslHotViewController.h"
#import "wslCategoryViewController.h"
#import "wslNewViewController.h"
#import "wslPicSearchViewController.h"

@interface wslwallpaperViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>


@property(nonatomic,strong) NSMutableArray * subVCs;

@property(nonatomic,strong) UIViewController * vc;

@end
//tag  70 --- 80
@implementation wslwallpaperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
  }

-(void)setupUI
{
    self.view.backgroundColor = [UIColor brownColor];
    [self.view  addSubview:self.pageViewController.view];
    self.navigationController.navigationBar.hidden = YES;
    NSArray * titleArray = @[@"推荐",@"分类",@"最新",@"搜索"];
    for(int i = 0; i < 4; i++){
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(i * 75 + 75/2.0, 20, 75, 35)];
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        button.tag = i + 70;
        [button addTarget:self action:@selector(titleClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view  addSubview:button];
        
    }
    
    UIScrollView * scr = [[UIScrollView alloc] initWithFrame:CGRectMake(75/2.0, 55, 75 * 4, 4)];
    scr.showsVerticalScrollIndicator = NO;
    scr.contentSize = CGSizeMake(4 * 75, 4);
    scr.contentOffset = CGPointMake(0, 0);
    scr.backgroundColor = [UIColor clearColor];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0 , 0, 75, 4)];
    label.tag = 80;
    label.backgroundColor = [UIColor  redColor];
    [scr  addSubview:label];
    
    [self.view  addSubview:scr];

}
#pragma mark  ---- Events Handle
-(void)titleClicked:(UIButton *)btn
{
    //判断将要滑动的方向
    if (self.vc.view.tag < btn.tag-70) {
     [self.pageViewController setViewControllers:@[_subVCs[btn.tag-70]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    else{
         [self.pageViewController setViewControllers:@[_subVCs[btn.tag-70]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
    UILabel * label = (UILabel *)[self.view  viewWithTag:80];
    CGRect  rect =  label.frame;
    UIViewController * vc = _subVCs[btn.tag-70];
    rect.origin.x =  vc.view.tag  * 75 ;
    label.frame = rect;
    //获得当前页面
    self.vc = _subVCs[btn.tag-70];
    
}

#pragma mark ---- UIPageViewControllerDataSource,UIPageViewControllerDelegate

// 返回viewController页面的后面的视图控制器
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if (viewController.view.tag < 3) {
        return _subVCs[viewController.view.tag + 1];
    }
    return nil;
}

// 返回viewController页面的前面的视图控制器
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController.view.tag > 0) {
       return self.subVCs[viewController.view.tag - 1];
    }
    return nil;
}

// 即将翻页到pendingViewControllers
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
  
    UIViewController * cv = [pendingViewControllers lastObject];
    self.vc = cv;
}

// 已经完成翻页completed ＝ YES 表示翻到另一个页面，NO表示没有翻到下一个页面
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    //previousViewControllers 上一页面
    
   if (completed == YES) {
       UILabel * label = (UILabel *)[self.view  viewWithTag:80];
       CGRect  rect =  label.frame;
       rect.origin.x =  self.vc.view.tag  * 75 ;
       label.frame = rect;
   }
    
}
#pragma mark ---- Getter

-(UIPageViewController *)pageViewController
{
    if (_pageViewController == nil) {
        // 创建页面控制器
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.view.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 40);
        [self.view addSubview:_pageViewController.view];
        
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        
        // 实现子页面内容
        
        NSArray * controllersArray = @[[wslHotViewController class],[wslCategoryViewController class],[wslNewViewController class],[wslPicSearchViewController class]];
        
        NSMutableArray * mArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 4; i++) {
            UIViewController * vc = [[controllersArray[i] alloc] init];
            
            vc.view.tag = i;
            [mArray addObject:vc];
        }
        
        self.subVCs = mArray;
        
        // 将页面内容放入页面控制器中显示
        [self.pageViewController setViewControllers:@[self.subVCs[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    return _pageViewController;
}

-(NSMutableArray *)subVCs
{
    if (_subVCs == nil) {
        _subVCs = [[NSMutableArray alloc] init];
    }return _subVCs;
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
