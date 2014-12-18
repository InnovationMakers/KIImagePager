//
//  INMImageView.m
//  Public
//
//  Created by Marlon Tojal on 29/04/14.
//  Copyright (c) 2014 Innovation Makers. All rights reserved.
//

#import "INMImageView.h"
#import "UIImageView+AFNetworking.h"

@interface INMImageView()

@property (nonatomic, strong) NSArray* images;
@property (nonatomic) int currentIndex;

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage;
@end

@implementation INMImageView

-(void)dealloc{
    NSLog(@"DEALLOC:%p --> %d", self , self.tag);
    [self stopAnimating];
    self.delegate = nil;
}

-(NSArray *)animationImages{
    return self.images;
}

-(void)setAnimationImages:(NSArray *)animationImages{
    _images = animationImages;
    if (self.animationImages.count > 0){
        [self loadImage:[animationImages firstObject]];
    }
}

-(void)spinView:(UIView *)view forDuration:(CGFloat)duration
               reverse:(BOOL)reverse
           repeatCount:(NSUInteger)repeatCount {
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:(2 * M_PI)]];
    [anim setFromValue:[NSNumber numberWithDouble:0.0f]];
    [anim setDuration:duration];
    [anim setRepeatCount:repeatCount];
    [anim setAutoreverses:reverse];
    [anim setRemovedOnCompletion:YES];
    [view.layer addAnimation:anim forKey:@"Spin"];
}


-(void)loadImage:(NSString *)imageURL{
    
    UIImageView* rotation = [[UIImageView alloc]initWithFrame:self.bounds];
    [rotation setImage:[UIImage imageNamed:@"xh_arrow"]];
    [rotation setContentMode:UIViewContentModeCenter];
    [self addSubview:rotation];
    
    UIImageView* camera = [[UIImageView alloc]initWithFrame:self.bounds];
    [camera setImage:[UIImage imageNamed:@"icon_machine_white"]];
    [camera setContentMode:UIViewContentModeCenter];
    [self addSubview:camera];

    [self spinView:rotation forDuration:3.0 reverse:NO repeatCount:NSIntegerMax];
    
    [self setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]] placeholderImage:nil
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            [rotation removeFromSuperview];
            [camera removeFromSuperview];
            [self setImage:image];
        
    }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [rotation removeFromSuperview];
            [camera removeFromSuperview];
            [self setContentMode:UIViewContentModeCenter];
            [self setImage:[UIImage imageNamed:@"icon-placeholder"]];
    }];
    
    
    //[self setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:self.placeholderImage];
}

-(void)startAnimating{
    [self performSelector:@selector(performTransition) withObject:nil afterDelay:self.animationDuration];
    NSLog(@"Starting animation for image %d %@", self.tag, [NSDate date]);
}

-(void)stopAnimating{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)performTransition {
    
    NSLog(@"%p --> %d", self , self.tag);
    
    if (self.animationImages.count > 0){
        self.currentIndex =  (self.currentIndex + 1) % self.animationImages.count;
    }
    
    NSLog(@"IDX:%d", self.currentIndex);
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRestartAnimation:)] && self.currentIndex == 0) {
        [self stopAnimating];
        NSLog(@"Called delegate for image %d", self.tag);
        NSLog(@"-----------------------------");
        [self.delegate didRestartAnimation:self];
    } else if (self.animationImages.count > 1) {
        NSLog(@"Firing animation for image %d %@", self.tag, [NSDate date]);
        [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(){
            [self loadImage:[self.animationImages objectAtIndex:self.currentIndex]];
        } completion:^(BOOL completion){
            [self startAnimating];
        }];
    }

}

@end
