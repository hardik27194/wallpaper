//
//  wslNewViewController.m
//  壁纸
//
//  Created by qianfeng on 15/10/10.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "AppDelegate.h"

#import "wslNewViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"

#import "wslCustomCollectionViewCell.h"
#import "wslPicDetailViewController.h"

@interface wslNewViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    
        int _limitCount;

}
@property (nonatomic,strong) UICollectionView *collectionView;

@property(nonatomic,strong) NSMutableArray * picturesArray;
@property(nonatomic,strong) NSMutableArray * picIdArr;

@end

@implementation wslNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}
-(void)setupUI
{
    _limitCount = 30;
    [self.view  addSubview:self.collectionView];
    [self downloadPictureData];
    
    //避免强强循环引用self --> block -->self
    __weak wslNewViewController * weakSelf = self;
    [self.collectionView addPullToRefreshWithActionHandler:^{
        [weakSelf downloadPictureData];
    }];
    [self.collectionView.pullToRefreshView setTitle:@"正在努力加载中..." forState:SVPullToRefreshStateLoading];
    // 当滚动到底部的时候会触发block(加载更多)
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf downloadPictureData];
    }];

}
#pragma mark ---- downloadPictureData
-(void)downloadPictureData
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    NSString * urlStr = [NSString stringWithFormat:@"http://service.picasso.adesk.com/v1/wallpaper/wallpaper?order=new&adult=false&first=1&limit=%d",_limitCount];
    
    [manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * picArray = responseObject[@"res"][@"wallpaper"];
        for (int i = _limitCount - 30; i < picArray.count ; i++) {
            [self.picturesArray addObject: picArray[i][@"img"]];
            [self.picIdArr  addObject:picArray[i][@"id"]];
        }
        
        //让下拉刷新的控件停掉
        [self.collectionView.pullToRefreshView stopAnimating];
        //让加载更多动画停掉
        [self.collectionView.infiniteScrollingView  stopAnimating];
        _limitCount += 30;
        
        [self.collectionView  reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@",error);
    }];
}
#pragma mark  --- UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.picturesArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    wslCustomCollectionViewCell * item  = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemID" forIndexPath:indexPath];
    [item.imageView  sd_setImageWithURL:[NSURL URLWithString:self.picturesArray[indexPath.item]] placeholderImage:[UIImage imageNamed:@"head"]];
    return item;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    wslPicDetailViewController * picDetailVc = [[wslPicDetailViewController alloc] init];
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    picDetailVc.imgUrlStr = self.picturesArray[indexPath.row];
    picDetailVc.imgID = self.picIdArr[indexPath.row];
    [dele.rootNavc pushViewController:picDetailVc animated:YES];

}
#pragma mark ---- Getter
-(UICollectionView *)collectionView
{
    if(_collectionView == nil){
        UICollectionViewFlowLayout * flow = [[UICollectionViewFlowLayout alloc] init];
        flow.itemSize = CGSizeMake((375 - 30) /2.0, 150);
        flow.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height) collectionViewLayout:flow];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor =  [UIColor brownColor];
        _collectionView.scrollEnabled = YES;
        //注册UICollectionViewcell
        [_collectionView  registerNib:[UINib nibWithNibName:@"wslCustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"itemID"];
    }
    return _collectionView;
}
-(NSMutableArray *)picturesArray
{
    if (_picturesArray == nil) {
        _picturesArray = [[NSMutableArray alloc] init];
    }return _picturesArray;
}
-(NSMutableArray *)picIdArr
{
    if (_picIdArr == nil) {
        _picIdArr = [[NSMutableArray alloc] init];
    }return _picIdArr;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
