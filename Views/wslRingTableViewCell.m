//
//  wslRingTableViewCell.m
//  壁纸
//
//  Created by qianfeng on 15/10/12.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "wslRingTableViewCell.h"
#import "AFNetworking.h"

@implementation wslRingTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
// 下载Rings
- (IBAction)downloadRing:(id)sender {
    
    NSString *RingsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"downloadRings"];
    
    //把音乐名字作为存储的MP3的名字
    NSString * RingPath = [RingsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",self.nameLabel.text]];
    
    NSFileManager * fm = [NSFileManager defaultManager];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.fid]];
    NSProgress *progress = nil;
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        // targetPath 系统缓存文件的URL
        // 这里需要把我们目标的URL返回给AFNetworking
        
        if (![fm fileExistsAtPath:RingsPath]) {
            //创建Rings文件夹
            [fm createDirectoryAtPath:RingsPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if([fm fileExistsAtPath:RingPath])
        {
            [fm removeItemAtPath:RingPath error:nil];
        }
        return [NSURL fileURLWithPath:RingPath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            NSLog(@"下载失败，错误是%@", error);
        }
        else {
            NSLog(@"下载成功");
        }
    }];
    [task resume];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
