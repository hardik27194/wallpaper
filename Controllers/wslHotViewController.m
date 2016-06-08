//
//  wslHotViewController.m
//  壁纸
//
//  Created by qianfeng on 15/10/10.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "AppDelegate.h"

#import "wslHotViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AFNetworking.h"

#import "wslwallpaperViewController.h"
#import "wslVideoPlayerView.h"
#import "wslCustomTableViewCell.h"

NSURL * _url ;
@interface wslHotViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) AVPlayer * videoPlayer;
@property(nonatomic,strong) UITableView * tableView;
@property(nonatomic,strong) NSMutableArray * xinPictureArray;
@property(nonatomic,strong) NSMutableArray * xinPicIDArr;

@property(nonatomic,strong) NSMutableArray * hotPicturesArray;
@property(nonatomic,strong) NSMutableArray * hotPicIDArr;
@end

@implementation wslHotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserverForAVPlayer];
    [self setupUI];
    [self downloadPictureData];
}
#pragma mark ---- downloadPictureData
-(void)downloadPictureData
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    [manager GET:@"http://service.picasso.adesk.com/v2/homepage?order=hot&adult=false&first=1&limit=60" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray * hotArray = responseObject[@"res"][@"wallpaper"];
        for (int i = 0; i < hotArray.count ; i++) {
            [self.hotPicturesArray addObject: hotArray[i][@"img"]];
            [self.hotPicIDArr   addObject:hotArray[i][@"id"]];
        }
        NSArray * newArray = responseObject[@"res"][@"homepage2"][3][@"items"];
        for ( int i = 0; i < newArray.count ; i++) {
            [self.xinPictureArray  addObject:newArray[i][@"img"]] ;
            [self.xinPicIDArr   addObject:newArray[i][@"id"]];
        }
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@",error);
    }];
}
#pragma mark ---  Help  Methods
-(void)setupUI
{
    self.view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.tableView];
}
- (void)addObserverForAVPlayer
{
    // 如果不想Block对一个对象强引用，就用__weak来修饰这个变量
    __weak wslHotViewController *weakSelf = self;

    [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1*3, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 当前播放的时间
        float playSeconds = self.videoPlayer.currentTime.value *1.0f / self.videoPlayer.currentTime.timescale;
        // 总的时间的秒数
        float totalSeconds = (self.videoPlayer.currentItem.duration.value *1.0f / self.videoPlayer.currentItem.duration.timescale);
        if (playSeconds >= totalSeconds- 0.001) {
            static int i = 0;
            i++;
            if (i < 20) {
         AVPlayerItem *playerItem =  [AVPlayerItem playerItemWithURL:_url];
            [weakSelf.videoPlayer  replaceCurrentItemWithPlayerItem:playerItem];
            [weakSelf.videoPlayer play];
            }else{[weakSelf.videoPlayer pause];}
        }
    }];
}
#pragma mark  ---- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   wslCustomTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.picturesArray = self.xinPictureArray;
        cell.picIdArr = self.xinPicIDArr;
    }else
    {   cell.picIdArr = self.hotPicIDArr;
        cell.picturesArray = self.hotPicturesArray;
      }
    if (self.xinPictureArray.count != 0 && self.hotPicturesArray.count != 0) {
        
        [cell reloadData];}
    
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 50,20)];
    if (section == 0) {
        label.text = @"最新";
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, 0, 50, 25)];
        [button setTitle:@"更多" forState:UIControlStateNormal];
        [button  addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [view addSubview:button];
    }else{ label.text = @"热门";};
    
    label.textColor = [UIColor whiteColor];
    [view  addSubview:label];
    return view;
}
-(void)moreBtnClicked:(UIButton *)btn
{
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    UINavigationController * na = dele.rootNavc;
    wslwallpaperViewController * vc = [na.viewControllers lastObject];
    UIButton * button = [[UIButton alloc] init];
    button.tag = 72;
    [vc titleClicked:button];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   if(indexPath.section == 1){
      return self.hotPicturesArray.count / 2 * 150 + 300 ;        }
           else{
    return 300;}
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}
#pragma mark  --- Getter
-(UITableView *)tableView
{
    if (_tableView == nil) {
        
       wslVideoPlayerView *videoView = [[wslVideoPlayerView alloc] initWithFrame:CGRectMake(15 ,0, 345, 250) player:self.videoPlayer];
        videoView.backgroundColor = [UIColor brownColor];
        [self addTapGesture:videoView];
        
        self .automaticallyAdjustsScrollViewInsets = YES;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-20) style:UITableViewStyleGrouped];
        _tableView.backgroundColor =  [UIColor brownColor];
        _tableView.separatorStyle = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableHeaderView = videoView;
        [_tableView registerClass:[wslCustomTableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}
#pragma mark ----  添加手势
-(void)addTapGesture:(UIView *)view{
    //创建点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    //设置点击次数
   tap.numberOfTapsRequired = 1;
    //给view添加手势
    [view addGestureRecognizer:tap];
}
-(void)tap:(UITapGestureRecognizer *)ta
{   static int isPlaying = 1;
    if (isPlaying == 1) {
        [self.videoPlayer pause];
        isPlaying = 0;
    }else
    {
        [self.videoPlayer play];
        isPlaying = 1;
    }
    
}
-(AVPlayer *)videoPlayer
{
    if (_videoPlayer == nil) {
        
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString * dateStr  = [dateFormatter stringFromDate:[NSDate date]];
        NSRange range = {0,2};
        NSString  *hour = [dateStr substringWithRange:range];
        NSLog(@"%@",hour);
        if ([hour intValue] >= 19) {
        _url = [[NSBundle    mainBundle]URLForResource:@"night.mp4" withExtension:nil];
        }else
        {
           _url = [[NSBundle    mainBundle]URLForResource:@"light.mp4" withExtension:nil];
        }
   AVPlayerItem  *  playerItem = [AVPlayerItem playerItemWithURL:_url];
        _videoPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];

    }return _videoPlayer;
}
-(NSMutableArray *)hotPicturesArray
{
    if (_hotPicturesArray == nil) {
        _hotPicturesArray = [[NSMutableArray alloc] init];
    }return _hotPicturesArray;
}
-(NSMutableArray *)hotPicIDArr
{
    if (_hotPicIDArr == nil) {
        _hotPicIDArr = [[NSMutableArray alloc] init];
    }return _hotPicIDArr;
}
-(NSMutableArray *)xinPictureArray
{
    if (_xinPictureArray == nil) {
        _xinPictureArray = [[NSMutableArray alloc] init];
    }return _xinPictureArray;
}
-(NSMutableArray *)xinPicIDArr
{
    if (_xinPicIDArr == nil) {
        _xinPicIDArr = [[NSMutableArray alloc] init] ;
    }return _xinPicIDArr;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.videoPlayer play];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.videoPlayer pause];
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
