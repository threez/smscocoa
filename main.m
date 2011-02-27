//
//  main.m
//  SMSSend
//
//  Created by Vincent Landgraf on 19.02.11.
//  Copyright 2011 Vincent Landgraf. All rights reserved.
//

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
