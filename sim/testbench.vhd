-----------------------------------------------------------------------------
--  LEON3 Demonstration design test bench
--  Copyright (C) 2004 Jiri Gaisler, Gaisler Research
------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2023, Cobham Gaisler
--  Copyright (C) 2023 - 2024, Frontgrade Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; version 2.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library gaisler;
use gaisler.libdcom.all;
use gaisler.sim.all;
library techmap;
use techmap.gencomp.all;
library micron;
use micron.components.all;
use work.debug.all;

use work.config.all;

entity testbench is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    clktech   : integer := CFG_CLKTECH;
    clkperiod : real := 14.3           -- system clock period
    );
end;


architecture behav of testbench is
  constant sdramfile : string  := "/dev/null";       -- sdram contents

  constant ct       : real := clkperiod/2.0;

  signal clk        : std_logic := '0';
  signal rst        : std_logic := '0';
  signal rstn      : std_logic;
  signal error      : std_logic;

  -- PROM flash
  signal address    : std_logic_vector(26 downto 0):=(others =>'0');
  signal data       : std_logic_vector(31 downto 0);
  signal RamCE      : std_logic;
  signal oen        : std_ulogic;
  signal writen     : std_ulogic;

  -- Debug support unit
  signal dsubre     : std_ulogic;

  -- AHB Uart
  signal dsurx      : std_ulogic;
  signal dsutx      : std_ulogic;

  -- APB Uart
  signal urxd       : std_ulogic;
  signal utxd       : std_ulogic;

  -- Output signals for LEDs
  signal led       : std_logic_vector(15 downto 0);


  procedure uart_tx (tx : integer) is
  begin
    assert false severity failure;
  end uart_tx;

  procedure uart_tx_bit (tx : std_logic) is
  begin
    if tx = '0' then
      uart_tx(0);
    else
      uart_tx(1);
    end if;
  end uart_tx_bit;

  function uart_rx return integer is
  begin
    assert false severity failure;
  end uart_rx;

  function uart_rx_bit return std_logic is
  begin
    if uart_rx = 0 then
      return '0';
    else
      return '1';
    end if;
  end uart_rx_bit;

  attribute foreign of uart_tx : procedure  is "VHPIDIRECT uart_tx";
  attribute foreign of uart_rx : function  is "VHPIDIRECT uart_rx";

begin
  -- clock and reset
  rst        <= '1', '0' after 100 ns;
  rstn       <= not rst;
  dsubre     <= '0';
  
  tickloop : process
  begin
    clk <= '1';
    wait for ct * 1.0 ns;
    --urxd <= uart_rx_bit;
    --uart_tx_bit(utxd);
    clk <= '0';
    wait for ct * 1.0 ns;
  end process;

  d3 : entity work.leon3mp
    generic map (fabtech, memtech, padtech, clktech)
    port map (
      clk     => clk,
      btnCpuResetn => rstn,
      
      -- PROM
      address   => address(22 downto 0),
      data      => data(31 downto 16),
      
      RamOE     => oen,
      RamWE     => writen,
      RamCE     => RamCE,
  
      -- AHB Uart
      RsRx     => dsurx,
      RsTx     => dsutx,

      -- Output signals for LEDs
      led       => led,

      urxd      => urxd,
      utxd      => utxd
      );

  sram0 : sram
    generic map (index => 4, abits => 24, fname => sdramfile, clear => 1)
    port map (address(23 downto 0), data(31 downto 24), RamCE, writen, oen);

  sram1 : sram
    generic map (index => 5, abits => 24, fname => sdramfile, clear => 1)
    port map (address(23 downto 0), data(23 downto 16), RamCE, writen, oen);

    
  led(3) <= 'H';            -- ERROR pull-up
  error <= led(3);      

  iuerr : process
  begin
    wait for 5 us;
    if to_x01(error) = '1' then wait on error; end if;
    assert (to_X01(error) = '1')
      report "*** IU in error mode, simulation halted ***"
      severity failure;
  end process;

  data <= buskeep(data) after 5 ns;
end;


