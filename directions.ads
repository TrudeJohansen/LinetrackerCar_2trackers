package Directions is
   
   task sense with Priority => 2; --høyest prioritet
   task act with Priority => 1;   --Lavest prioritet 
   
   type rettning is (Forward, Right, Left, Stop);
   
   procedure drive(dir: rettning);
   procedure findLine;
   
   protected directionobj is
      procedure setDirection(dir: rettning );
      function getDirection return rettning;
      procedure readLinetracker(trackerstateL, trackerstateR: Boolean);
      function getLinetracker_Left return Boolean;
      function getLinetracker_Right return Boolean;


   private
      dir_value: rettning;
      linetrackerState_left : Boolean;
      linetrackerState_right : Boolean;

   end directionobj;
   
end Directions;
