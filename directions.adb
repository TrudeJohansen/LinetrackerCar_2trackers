with MicroBit.IOsForTasking;
with MicroBit;
with MicroBit.Console; use MicroBit.Console;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO; -- instead of MicroBit.Console we can also use Ada.Text_IO (in the Serial Ports view) for convenience which use the same API's
with Ada.Execution_Time; use Ada.Execution_Time;


package body Directions is
   
   protected body directionobj is
      ---Gives the private value dir_value a new value with an input--
      procedure setDirection(dir: rettning ) is
         begin
         dir_value := dir;
      end setDirection;
      
      -- returns the private value dir_value -------------------------
      function getDirection return rettning is 
      begin
         return dir_value;
      end getDirection;
      
      --Reads from the linetracker: ----------------------------------
      procedure readLinetracker(trackerstateL, trackerstateR: Boolean) is
      begin 
         linetrackerState_left := trackerstateL;
         linetrackerState_right := trackerstateR;
      end readLinetracker;
      
      --Returns the private value linetrackerState_left--------------
      function getLinetracker_Left return Boolean is
      begin 
         return linetrackerState_left;
      end getLinetracker_Left;
      
      --Returns the private value linetrackerState_right--------------
      function getLinetracker_Right return Boolean is
      begin 
         return linetrackerState_right;
      end getLinetracker_Right;

      
   end directionobj;
   --Make sure that the linetrackers finds the line by turn the car depending on which line tracker has no signal-
   procedure findLine is
      ltState_Left : Boolean;
      ltState_Right : Boolean;
   begin 
      ltState_Left := directionobj.getLinetracker_Left;
      ltState_Right := directionobj.getLinetracker_Right;
      
      if ltState_Left = false then 
         directionobj.setDirection(Right);
         drive(Right);
         Ada.Text_IO.Put_Line("Turn Right");
      end if;
      
      if ltState_Right = false then 
         directionobj.setDirection(Left);
         drive(Left);
         Ada.Text_IO.Put_Line("Turn Left");
      end if;
      
      if ltState_Right = false and ltState_Left = false then
         directionobj.setDirection(Stop);
         drive(Stop);
         Ada.Text_IO.Put_Line("STOPP");
      end if;
  
   end findLine;
   
   
   -- define the various directions the car can drive ------------------
   procedure drive(dir: rettning) is
      Speed : constant MicroBit.IOsForTasking.Analog_Value := 1023;
   begin
      MicroBit.IOsForTasking.Set_Analog_Period_Us(20000); -- 50 Hz = 1/50 = 0.02s = 20 ms = 20000us 
      if dir = Forward then
         --LEFT
         --front   
         MicroBit.IOsForTasking.Set(6, True); --IN1
         MicroBit.IOsForTasking.Set(7, False); --IN2
   
         --back
         MicroBit.IOsForTasking.Set(2, True); --IN3
         MicroBit.IOsForTasking.Set(3, False); --IN4
   
         --RIGHT
         --front
         MicroBit.IOsForTasking.Set(12, True); --IN1
         MicroBit.IOsForTasking.Set(13, False); --IN2

         --back
         MicroBit.IOsForTasking.Set(14, True); --IN3
         MicroBit.IOsForTasking.Set(15, False); --IN4
   
         MicroBit.IOsForTasking.Write (0, Speed); --left speed control ENA ENB
         MicroBit.IOsForTasking.Write (1, Speed); --right speed control ENA ENB
      end if;
      
      if dir = Left then 
         --LEFT
         --front   
         MicroBit.IOsForTasking.Set(6, False); --IN1
         MicroBit.IOsForTasking.Set(7, True); --IN2

         --back
         MicroBit.IOsForTasking.Set(2, False); --IN3
         MicroBit.IOsForTasking.Set(3, False); --IN4
   
         --RIGHT
         --front
         MicroBit.IOsForTasking.Set(12, True); --IN1
         MicroBit.IOsForTasking.Set(13, False); --IN2

         --back
         MicroBit.IOsForTasking.Set(14, False); --IN3
         MicroBit.IOsForTasking.Set(15, False); --IN4
   
         MicroBit.IOsForTasking.Write (0, Speed); --left speed control ENA ENB
         MicroBit.IOsForTasking.Write (1, Speed); --right speed control ENA ENB
      end if; 
      
      if dir = Right then
         --LEFT
         --front   
         MicroBit.IOsForTasking.Set(6, True); --IN1
         MicroBit.IOsForTasking.Set(7, False); --IN2

         --back
         MicroBit.IOsForTasking.Set(2, False); --IN3
         MicroBit.IOsForTasking.Set(3, False); --IN4
   
         --RIGHT
         --front
         MicroBit.IOsForTasking.Set(12, False); --IN1
         MicroBit.IOsForTasking.Set(13, True); --IN2

         --back
         MicroBit.IOsForTasking.Set(14, False); --IN3
         MicroBit.IOsForTasking.Set(15, False); --IN4
   
            
         MicroBit.IOsForTasking.Write (0, Speed); --left speed control ENA ENB
         MicroBit.IOsForTasking.Write (1, Speed); --right speed control ENA ENB
      end if; 
      
      if dir = Stop then
         --LEFT
         --front   
         MicroBit.IOsForTasking.Set(6, False); --IN1
         MicroBit.IOsForTasking.Set(7, False); --IN2
   
         --back
         MicroBit.IOsForTasking.Set(2, False); --IN3
         MicroBit.IOsForTasking.Set(3, False); --IN4
   
         --RIGHT
         --front
         MicroBit.IOsForTasking.Set(12, False); --IN1
         MicroBit.IOsForTasking.Set(13, False); --IN2

         --back
         MicroBit.IOsForTasking.Set(14, False); --IN3
         MicroBit.IOsForTasking.Set(15, False); --IN4
   
         MicroBit.IOsForTasking.Write (0, 0); --left speed control ENA ENB
         MicroBit.IOsForTasking.Write (1, 0); --right speed control ENA ENB
      end if;
      
   end drive;
   ----------------------------------------------------------------------------------------  
   ---The sense task checks whether the car is on a line or not--------------
   task body sense is
      Time_Now : Ada.Real_Time.Time;
      linetrackerState : Boolean := True;

      AmountOfMeasurement: Integer := 10; -- do 10 measurement and average
   
   begin 
      loop
      Time_Now := Ada.Real_Time.Clock;
         
      directionobj.readLinetracker(MicroBit.IOsForTasking.set(10), MicroBit.IOsForTasking.set(4));
         
         delay until Time_Now + Ada.Real_Time.Milliseconds(20); 
      end loop;
   
   end sense;
   
   --- The act task are checking the linetracker state variables, and make the car drive according to given specifications-
   task body act is
      Time_Now : Ada.Real_Time.Time;
      dir : rettning;
      Speed : constant MicroBit.IOsForTasking.Analog_Value := 512;
      current_state : rettning := Forward;
      ltState_Left : Boolean;
      ltState_Right : Boolean;
      
   begin 
      loop

         Time_Now := Ada.Real_Time.Clock;
         

         dir := directionobj.getDirection;
         ltState_Left := directionobj.getLinetracker_Left;
         ltState_Right := directionobj.getLinetracker_Right;
     
      if ltState_Left = True and ltState_Right = True then 
            directionobj.setDirection(Forward);
            drive(Forward);
      else
         findLine;
         end if;
         
         Ada.Text_IO.Put_Line("Direction: " & rettning'Image(dir));
         
         
         delay until Time_Now + Ada.Real_Time.Milliseconds(20); 
      end loop;
   
   end act;
   
   
end Directions;
