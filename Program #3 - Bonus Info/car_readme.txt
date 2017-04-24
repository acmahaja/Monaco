
ECE109 Program #3   Bonus Points Info

The module car_icon.obj should be loaded along with your monaco.obj and the p3os.obj.

Access the module using the following instructions:

	   LD R1, Dc_Car_Base   ; load the starting point of the car icon
	   
Then Loop to read/write the pixels

Dc_XLoop LDR R0, R1, #0   
		STR R0, R2, #0		; Send Pixel


Dc_Car_Base	.FILL x4000	

		
