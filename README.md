# axis_insert_timing_system
a project that use xilinx video timing controller and axis2vidout and vidin2axis to add timing blanking hsync,vsync, hfp, hbp, vfp, vbp to video axi stream  
the purpose: make axis video stream contain the blanking infomation for high speed phy level ip to convert to correct packet to avoid the line crc error  
block design:  
![alt text](https://github.com/joshuahwfwEE/axis_insert_timing_system/blob/main/bd.png?raw=true)  
simulation result:  
![alt text](https://github.com/joshuahwfwEE/axis_insert_timing_system/blob/main/sim.png?raw=true)  
notice:  
1. locked bit of axis_to_vid_out will be asserted after tpg has already output four continous frames and vtc can make sure that it has already sync up with the stream source(vtg)  
2. vtc will start to generate the vtiming signal when it receive the valid axi video stream, and it will detect the sof signal and eof signal to form a completely frame and then start to waiting for synchronization with axi stream source  
3. because vtc is in master mode: the sync mechanism is depend on the precision pixel clock, the wrong clk will casue its can not lock correctly, ex: 1920x1080@30fps => 74.25M pixel clk, if it receive the wrong clk, the locked bit will not locked  
4.this design is in common clk mode: which is mean that all the data flow is in a same clk 74.25, if you want to change the resolution and fps, you need to re-customize the vtc's parameter and feed the system with the precision pixel clk  
     

