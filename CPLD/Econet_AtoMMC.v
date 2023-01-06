`timescale 1ns / 1ps
/************************************************************************
    Econet_AtoMMC.v


    This file forms part of the logic for the combined Atom Econet &
    AtoMMC module.

    Copyright (C) 2022 Ken Lowe

    Econet_AtoMMC is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Email: ken@skidog.co.uk

************************************************************************/

module Econet_AtoMMC(
   inout [7:0] Atom_Data,
   input [7:0] Econet_ID,
   input [3:0] Atom_Addr,
   output [2:0] PIC_Addr,

   input Atom_Phi2,
   input Atom_RnWR,
   input Atom_nB400,
   output Econet_nEn,
   output PIC_nRD,
   output PIC_nWR,
   output PIC_nEn
   );

   reg [2:0] Latched_PIC_Addr;

   assign PIC_Addr[0] = Latched_PIC_Addr[0];
   assign PIC_Addr[1] = Latched_PIC_Addr[1];
   assign PIC_Addr[2] = Latched_PIC_Addr[2];

   assign PIC_nRD = !(  Atom_RnWR & Atom_Phi2 & !Atom_Addr[3] & !Atom_nB400);
   assign PIC_nWR = !( !Atom_RnWR & Atom_Phi2 & !Atom_Addr[3] & !Atom_nB400);
   assign PIC_nEn = !(              Atom_Phi2 & !Atom_Addr[3] & !Atom_nB400);

   assign Econet_nEn = !(Atom_Addr[3] & !Atom_Addr[2] & !Atom_nB400);

   assign Atom_Data = (Atom_Phi2 & Atom_Addr[3] & Atom_Addr[2] & Atom_RnWR & !Atom_nB400) ? Econet_ID : 8'hZZ;

   // Latch the address in the middle of the cycle where a write to AtoMMC occurs
   always @(posedge Atom_Phi2) begin
      if (!Atom_nB400 && !Atom_Addr[3] && !Atom_RnWR) begin
         Latched_PIC_Addr[0] <= Atom_Addr[0];
         Latched_PIC_Addr[1] <= Atom_Addr[1];
         Latched_PIC_Addr[2] <= Atom_Addr[2];
      end
   end

endmodule
