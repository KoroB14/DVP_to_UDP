#!/usr/bin/env python
# coding: utf-8

import socket
import cv2
import numpy as np
from numba import njit, prange



@njit(parallel=True, cache=True)
def ProcessImageRGB (im_to_show, im_array):
    mask = [0X1F, 0X7E0, 0XF800]
    shift = [0, 5, 11]
    mul = [int(255/31), int(255/63), int(255/31)]
    for i in prange(3):
        im_to_show[:,:,i] = ((im_array & mask[i]) >> shift[i]) * mul[i]
        


def main():
    # Create a UDP socket
    
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM )
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 65536*4096)
        
    sock.setblocking(True)
    
    port = 1024
    ip = '192.168.1.1'
        
    sock.bind((ip,port))
    im_cnt = 0
    im_type = 0
    line_cnt = 0
    
    while(True):
        data = sock.recv(65536)
        
        if ((data[0] == 0xAA) or (data[0] == 0xBB)):
            if (im_type == 0):
                IM_X = data[1] + (data[2] << 8)
                IM_Y = data[3] + (data[4] << 8)
                PAC_PER_FRAME = data[5] + (data[6] << 8)
                PACK_PER_LINE = int(PAC_PER_FRAME / IM_Y)
                seg_len = int(IM_X / PACK_PER_LINE)
                if (data[0] == 0xAA):
                    im_array = np.zeros((IM_Y,IM_X),np.uint8)
                    im_type = 1
                    win_name = "FPGA video - " + str(IM_X) + "x" + str(IM_Y) + " grayscale"
                elif (data[0] == 0xBB):
                    im_array = np.zeros((IM_Y,IM_X),np.uint16)
                    im_to_show = np.zeros((IM_Y,IM_X,3),np.uint8)
                    im_type = 2
                    win_name = "FPGA video - " + str(IM_X) + "x" + str(IM_Y) + " RGB"
            PAC_CNT = (data[7] + (data[8] << 8))
            line_cnt = int(PAC_CNT / PACK_PER_LINE)
            offset = int(PAC_CNT % PACK_PER_LINE)
            seg_pointer = int(offset*seg_len)
            
            if (im_type == 1):
                im_array[line_cnt,seg_pointer:seg_pointer + seg_len] = np.frombuffer(data[9:], dtype=np.uint8);
            elif (im_type == 2):
                im_array[line_cnt,seg_pointer:seg_pointer + seg_len] = np.frombuffer(data[9:], dtype=np.uint16);
            
                
        if (line_cnt == IM_Y - 1):
            if (im_type == 1):
                im_to_show = im_array
            elif (im_type == 2):
                ProcessImageRGB(im_to_show, im_array)
                            
            cv2.imshow(win_name, im_to_show)
                    
            key = cv2.waitKey(1)
        
            if key == ord('s'):
                filename = "Img_" + str(im_cnt)+".bmp"
                im_to_save = np.array(im_to_show).copy()
                cv2.imwrite(filename,im_to_save)
                im_cnt += 1
                print ("Saved image " + filename)
            
            if key == ord('q'):
                break
            
    print("The client is quitting.")
    sock.close()
    cv2.destroyAllWindows()
    
if __name__ == '__main__':
    main()
