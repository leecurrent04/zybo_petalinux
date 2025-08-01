
-- ************************************************************************
-- ** DISCLAIMER OF LIABILITY                                            **
-- **                                                                    **
-- ** This file contains proprietary and confidential information of     **
-- ** Xilinx, Inc. ("Xilinx"), that is distributed under a license       **
-- ** from Xilinx, and may be used, copied and/or disclosed only         **
-- ** pursuant to the terms of a valid license agreement with Xilinx.    **
-- **                                                                    **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION              **
-- ** ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER         **
-- ** EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT                **
-- ** LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,          **
-- ** MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx      **
-- ** does not warrant that functions included in the Materials will     **
-- ** meet the requirements of Licensee, or that the operation of the    **
-- ** Materials will be uninterrupted or error-free, or that defects     **
-- ** in the Materials will be corrected. Furthermore, Xilinx does       **
-- ** not warrant or make any representations regarding use, or the      **
-- ** results of the use, of the Materials in terms of correctness,      **
-- ** accuracy, reliability or otherwise.                                **
-- **                                                                    **
-- ** Xilinx products are not designed or intended to be fail-safe,      **
-- ** or for use in any application requiring fail-safe performance,     **
-- ** such as life-support or safety devices or systems, Class III       **
-- ** medical devices, nuclear facilities, applications related to       **
-- ** the deployment of airbags, or any other applications that could    **
-- ** lead to death, personal injury or severe property or               **
-- ** environmental damage (individually and collectively, "critical     **
-- ** applications"). Customer assumes the sole risk and liability       **
-- ** of any use of Xilinx products in critical applications,            **
-- ** subject only to applicable laws and regulations governing          **
-- ** limitations on product liability.                                  **
-- **                                                                    **
-- ** Copyright 2010, 2013 Xilinx, Inc.                                  **
-- ** All rights reserved.                                               **
-- **                                                                    **
-- ** This disclaimer and copyright notice must be retained as part      **
-- ** of this file at all times.                                         **
-- ************************************************************************
-------------------------------------------------------------------------------

-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_arith.conv_std_logic_vector;
    use IEEE.std_logic_arith.unsigned;
    use IEEE.std_logic_arith.all;
    use IEEE.std_logic_misc.and_reduce;
    use IEEE.std_logic_misc.or_reduce;

library work;
    use work.system_video_dynclk_0_ipif_pkg.all;
    use work.system_video_dynclk_0_soft_reset;
    use work.system_video_dynclk_0_ipif_pkg.calc_num_ce;
    use work.system_video_dynclk_0_ipif_pkg.INTEGER_ARRAY_TYPE;
    use work.system_video_dynclk_0_ipif_pkg.SLV64_ARRAY_TYPE;
    use work.system_video_dynclk_0_ipif_pkg.INTR_POS_EDGE_DETECT;
    use work.system_video_dynclk_0_proc_common_pkg.all;


-------------------------------------------------------------------------------
--                     Definition of Generics
--------------------
-- AXI LITE Generics
--------------------
-- C_BASEADDR            -- Base Address
-- C_HIGHADDR            -- high address  
-- C_S_AXI_DATA_WIDTH    -- AXI data bus width
-- C_S_AXI_ADDR_WIDTH    -- AXI address bus width
-------------------------------------------------------------------------------
--                  Definition of Ports
-------------------------------------------------------------------------------
-- s_axi_aclk            -- AXI Clock
-- s_axi_aresetn          -- AXI Reset
-- s_axi_awaddr          -- AXI Write address
-- s_axi_awvalid         -- Write address valid
-- s_axi_awready         -- Write address ready
-- s_axi_wdata           -- Write data
-- s_axi_wstrb           -- Write strobes
-- s_axi_wvalid          -- Write valid
-- s_axi_wready          -- Write ready
-- s_axi_bresp           -- Write response
-- s_axi_bvalid          -- Write response valid
-- s_axi_bready          -- Response ready
-- s_axi_araddr          -- Read address
-- s_axi_arvalid         -- Read address valid
-- s_axi_arready         -- Read address ready
-- s_axi_rdata           -- Read data
-- s_axi_rresp           -- Read response
-- s_axi_rvalid          -- Read valid
-- s_axi_rready          -- Read ready
-------------------------------------------------------------------------------
-- Note: the unused signals in the port name lists are not listed here.
-------------------------------------------------------------------------------

entity system_video_dynclk_0_axi_clk_config is
  generic
  (
   -----------------------------------------
--   C_BASEADDR              : std_logic_vector  := X"FFFF_FFFF";
--   C_HIGHADDR              : std_logic_vector  := X"0000_0000";
   -----------------------------------------
   -- AXI slave single block generics
   C_S_AXI_ADDR_WIDTH      : integer range 2 to 32   := 11;
   C_S_AXI_DATA_WIDTH      : integer range 32 to 128  := 32
  );
  port
  (
  -- System interface
  s_axi_aclk      : in  std_logic;                                      
  s_axi_aresetn   : in  std_logic;                                      
  -- AXI Write address channel signals                                        
  s_axi_awaddr    : in  std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);                  
  s_axi_awvalid   : in  std_logic;                                      
  s_axi_awready   : out std_logic;                                      
  -- AXI Write data channel signals                                           
  s_axi_wdata     : in  std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);                  
  s_axi_wstrb     : in  std_logic_vector(((C_S_AXI_DATA_WIDTH/8)-1) downto 0);              
  s_axi_wvalid    : in  std_logic;                                      
  s_axi_wready    : out std_logic;                                      
  -- AXI Write response channel signals                                       
  s_axi_bresp     : out std_logic_vector(1 downto 0);                   
  s_axi_bvalid    : out std_logic;                                      
  s_axi_bready    : in  std_logic;                                      
  -- AXI Read address channel signals                                         
  s_axi_araddr    : in  std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);                  
  s_axi_arvalid   : in  std_logic;                                      
  s_axi_arready   : out std_logic;                                      
  -- AXI Read address channel signals                                         
  s_axi_rdata     : out std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);                  
  s_axi_rresp     : out std_logic_vector(1 downto 0);                   
  s_axi_rvalid    : out std_logic;                                      
  s_axi_rready    : in  std_logic;                                      
  -- Clock out ports
  pxl_clk_5x          : out    std_logic;
  -- Status and control signals
  locked            : out    std_logic;
  -- Clock in ports
  clk_in1           : in     std_logic
  );   

-------------------------------------------------------------------------------
-- Attributes
-------------------------------------------------------------------------------

   -- Fan-Out attributes for XST

   --ATTRIBUTE MAX_FANOUT                    : string;
   --ATTRIBUTE MAX_FANOUT   of s_axi_aclk    : signal is "10000";
   --ATTRIBUTE MAX_FANOUT   of s_axi_aresetn : signal is "10000";


end entity system_video_dynclk_0_axi_clk_config;
-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------

architecture imp of system_video_dynclk_0_axi_clk_config is

component system_video_dynclk_0_clk_wiz_drp 
  generic
  (
     ----------------
     C_S_AXI_ADDR_WIDTH     : integer;
     C_S_AXI_DATA_WIDTH     : integer;
     C_FAMILY               : string;
     ----------------
     CE_NUMBERS             : integer
     ----------------
  );
  port
  (
   -- IP Interconnect (IPIC) port signals ---------
  Bus2IP_Clk             : in  std_logic;
  Bus2IP_Rst             : in  std_logic;
  -- Bus 2 IP IPIC interface
  Bus2IP_RdCE            : in std_logic_vector(0 to CE_NUMBERS-1);
  Bus2IP_WrCE            : in std_logic_vector(0 to CE_NUMBERS-1);
  Bus2IP_Addr            : in std_logic_vector(0 to (C_S_AXI_ADDR_WIDTH-1));
  Bus2IP_Data            : in std_logic_vector(0 to (C_S_AXI_DATA_WIDTH-1));
  -- IP 2 Bus IPIC interface
  IP2Bus_Data     : out std_logic_vector(0 to (C_S_AXI_DATA_WIDTH-1));
  IP2Bus_WrAck    : out std_logic;
  IP2Bus_RdAck    : out std_logic;
  ----------------  clocking macro interface  -------------------
  -- Clock Monitor ports

  -- Clock out ports
  pxl_clk_5x          : out    std_logic;
  -- Status and control signals
  locked            : out    std_logic;
  -- Clock in ports
  clk_in1           : in     std_logic
   );

end component;

-------------------------------------------------------------------------------
-- Type Declaration
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Constant Declaration Starts
-------------------------------------------------------------------------------
 -- AXI lite parameters

constant    C_BASEADDR              : std_logic_vector  := X"0000_0000";
--constant    C_BASEADDR              : std_logic_vector  := X"FFFF_FFFF";
constant    C_HIGHADDR              : std_logic_vector  := X"0000_0000";
constant C_S_AXI_MIN_SIZE  : std_logic_vector(31 downto 0):= X"000007FF";
constant C_USE_WSTRB              : integer := 1;
constant C_DPHASE_TIMEOUT         : integer := 64;

--constant ZERO_ADDR_PAD   : std_logic_vector(0 to 64-C_S_AXI_ADDR_WIDTH-1)
--                         := (others => '0');
constant ZERO_ADDR_PAD   : std_logic_vector(0 to 64-32-1) := (others => '0');

-------------------------------------------------------------------------------
-- The local register array contains
-- 1. Software Reset Register (SRR),            -- address C_BASEADDR + 0x00
-- 2. Status Register (SR),                     -- address C_BASEADDR + 0x04
-- All registers are 32 bit width and their addresses are at word boundry.
-------------------------------------------------------------------------------
constant LOCAL_REG_BASEADDR : std_logic_vector  := C_BASEADDR or X"00000000";
constant LOCAL_REG_HIGHADDR : std_logic_vector  := C_BASEADDR or X"0000001F";
-------------------------------------------------------------------------------
-- The address range is devided in the range of Status & Control registers
-- there are total 128 registers. First 64 are the status and remaning 64 are
-- control registers
-------------------------------------------------------------------------------
constant REG_FILE_BASEADDR  : std_logic_vector  := C_BASEADDR or X"00000200";
constant REG_FILE_HIGHADDR  : std_logic_vector  := C_BASEADDR or X"000007FF";
-------------------------------------------------------------------------------
--The address ranges for the registers are defined in USER_ARD_ADDR_RANGE_ARRAY
-------------------------------------------------------------------------------
constant USER_ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE :=
         (
          ZERO_ADDR_PAD & LOCAL_REG_BASEADDR,
          ZERO_ADDR_PAD & LOCAL_REG_HIGHADDR,

          ZERO_ADDR_PAD & REG_FILE_BASEADDR,
          ZERO_ADDR_PAD & REG_FILE_HIGHADDR
          );

-------------------------------------------------------------------------------
--The total 128 DRP register address space is divided in two 64 register arrays
--The status and control registers are equally divided in the range to generate
--the chip enable signals.
--There are some local alarm registers, conversion start registers, ip reset
--registers present in the design.
--the no. of CE's required is defined in USER_ARD_NUM_CE_ARRAY array
-------------------------------------------------------------------------------
constant USER_ARD_NUM_CE_ARRAY : INTEGER_ARRAY_TYPE :=
         (
          0 => 8,   -- 5 chip enable + 3 dummy
                    --  CS_0 & CE_0 => program_status          -- Addr = 00

          1 => 1--, -- 1 chip enable
                    --  CS_1 & CE_8 => 1 CE required to access DRP
          );


constant SWRESET                : natural := 0;

constant CS_NUMBERS             : integer :=((USER_ARD_ADDR_RANGE_ARRAY'LENGTH/2));
constant RD_CE_NUMBERS          : integer :=(calc_num_ce(USER_ARD_NUM_CE_ARRAY));
constant WR_CE_NUMBERS          : integer :=(calc_num_ce(USER_ARD_NUM_CE_ARRAY));

constant RDCE_WRCE_CORE  : integer := 9;
--------------------------------------------------------------------------------
-- Constant Declaration Ends
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Signal and Type Declarations
--------------------------------------------------------------------------------
--bus2ip signals
signal bus2ip_clk       : std_logic;
signal bus2ip_reset     : std_logic;
---
signal bus2ip_rdce      : std_logic_vector((RD_CE_NUMBERS-1)downto 0);
signal bus2ip_rdce_int  : std_logic_vector(0 to (RD_CE_NUMBERS-1));
signal bus2ip_rdce_core : std_logic_vector(0 to (RDCE_WRCE_CORE-1));
---
signal bus2ip_wrce      : std_logic_vector((WR_CE_NUMBERS-1)downto 0);
signal bus2ip_wrce_int  : std_logic_vector(0 to (WR_CE_NUMBERS-1));
signal bus2ip_wrce_core : std_logic_vector(0 to (RDCE_WRCE_CORE-1));
---
signal bus2ip_addr      : std_logic_vector((C_S_AXI_ADDR_WIDTH-1)downto 0);
signal bus2ip_addr_int  : std_logic_vector(0 to (C_S_AXI_ADDR_WIDTH-1));
---
signal bus2ip_be        : std_logic_vector(((C_S_AXI_DATA_WIDTH/8)-1)downto 0);
signal bus2ip_be_int    : std_logic_vector(0 to (C_S_AXI_DATA_WIDTH/8)-1);
---
signal bus2ip_data      : std_logic_vector(((C_S_AXI_DATA_WIDTH)-1)downto 0);
signal bus2ip_data_int  : std_logic_vector(0 to (C_S_AXI_DATA_WIDTH-1));
-- ip2bus signals
signal ip2bus_data      : std_logic_vector((C_S_AXI_DATA_WIDTH-1)downto 0)
                          := (others => '0');
signal ip2bus_wrack     : std_logic;
signal ip2bus_rdack     : std_logic;
signal ip2bus_error     : std_logic;

signal ip2bus_wrack_int1     : std_logic;
signal ip2bus_rdack_int1     : std_logic;
signal ip2bus_error_int1     : std_logic;
signal ip2bus_wrack_core     : std_logic;
signal ip2bus_rdack_core     : std_logic;

-- Software Reset Signals
signal reset2ip_reset      : std_logic := '0';
signal rst_ip2bus_wrack    : std_logic;
signal rst_ip2bus_error    : std_logic;
signal rst_ip2bus_rdack    : std_logic;
signal rst_ip2bus_rdack_d1 : std_logic;

-- following signals are used to impleemnt the register access rule
signal and_reduce_be : std_logic;
signal partial_reg_access_error : std_logic;

signal bus2ip_reset_active_low : std_logic;

signal bus2ip_reset_active_high: std_logic;
--------------------------------------------
signal dummy_local_reg_rdack_d1 : std_logic;
signal dummy_local_reg_rdack    : std_logic;
signal dummy_local_reg_wrack_d1 : std_logic;
signal dummy_local_reg_wrack    : std_logic;

-------------------------------------------------------------------------------
-- Architecture begins
-------------------------------------------------------------------------------
begin
--------------------------------------------
-- INSTANTIATE AXI SLAVE SINGLE
--------------------------------------------
AXI_LITE_IPIF_I : entity work.system_video_dynclk_0_axi_lite_ipif
  generic map
   (
    C_S_AXI_ADDR_WIDTH        => C_S_AXI_ADDR_WIDTH,
    C_S_AXI_DATA_WIDTH        => C_S_AXI_DATA_WIDTH,

    C_S_AXI_MIN_SIZE          => C_S_AXI_MIN_SIZE,
    C_USE_WSTRB               => C_USE_WSTRB,
    C_DPHASE_TIMEOUT          => C_DPHASE_TIMEOUT,

    C_ARD_ADDR_RANGE_ARRAY    => USER_ARD_ADDR_RANGE_ARRAY,
    C_ARD_NUM_CE_ARRAY        => USER_ARD_NUM_CE_ARRAY,
    C_FAMILY                  => "virtex7"
   )
 port map
   (
    s_axi_aclk                => s_axi_aclk,           -- in
    s_axi_aresetn             => s_axi_aresetn,        -- in

    s_axi_awaddr              => s_axi_awaddr,         -- in
    s_axi_awvalid             => s_axi_awvalid,        -- in
    s_axi_awready             => s_axi_awready,        -- out
    s_axi_wdata               => s_axi_wdata,          -- in
    s_axi_wstrb               => s_axi_wstrb,          -- in
    s_axi_wvalid              => s_axi_wvalid,         -- in
    s_axi_wready              => s_axi_wready,         -- out
    s_axi_bresp               => s_axi_bresp,          -- out
    s_axi_bvalid              => s_axi_bvalid,         -- out
    s_axi_bready              => s_axi_bready,         -- in
    
    s_axi_araddr              => s_axi_araddr,         -- in
    s_axi_arvalid             => s_axi_arvalid,        -- in
    s_axi_arready             => s_axi_arready,        -- out
    s_axi_rdata               => s_axi_rdata,          -- out
    s_axi_rresp               => s_axi_rresp,          -- out
    s_axi_rvalid              => s_axi_rvalid,         -- out
    s_axi_rready              => s_axi_rready,         -- in

 -- IP Interconnect (IPIC) port signals
    Bus2IP_Clk                => bus2ip_clk,           -- out
    Bus2IP_Resetn             => bus2ip_reset_active_low,     -- out

    Bus2IP_Addr               => bus2ip_addr,          -- out
    Bus2IP_RNW                => open,                 -- out
    Bus2IP_BE                 => bus2ip_be,            -- out
    Bus2IP_CS                 => open,                -- out
    Bus2IP_RdCE               => bus2ip_rdce,          -- out
    Bus2IP_WrCE               => bus2ip_wrce,          -- out
    Bus2IP_Data               => bus2ip_data,          -- out

    IP2Bus_Data               => ip2bus_data,          -- in
    IP2Bus_WrAck              => ip2bus_wrack,         -- in
    IP2Bus_RdAck              => ip2bus_rdack,         -- in
    IP2Bus_Error              => ip2bus_error          -- in
   );
-------------------------------------------------------------------------------

-------------------------------
bus2ip_rdce_int <= bus2ip_rdce;
-------------------------------
bus2ip_wrce_int	<= bus2ip_wrce;
-------------------------------
----------------------
--REG_RESET_FROM_IPIF: convert active low to active hig reset to rest of
--                     the core.
----------------------
REG_RESET_FROM_IPIF: process (s_axi_aclk) is
begin
     if(s_axi_aclk'event and s_axi_aclk = '1') then
         bus2ip_reset_active_high <= not(bus2ip_reset_active_low);
     end if;
end process REG_RESET_FROM_IPIF;
----------------------



  bus2ip_rdce_core <= bus2ip_rdce_int;
  bus2ip_wrce_core <= bus2ip_wrce_int;

---------------------------------
-------------------------------------------------------------------------------

--------------------------------------------
-- XADC_CORE_I: INSTANTIATE XADC CORE
--------------------------------------------

CLK_CORE_DRP_I : system_video_dynclk_0_clk_wiz_drp
   generic map
   (
   ----------------              -------------------------
   C_S_AXI_ADDR_WIDTH            => C_S_AXI_ADDR_WIDTH,
   C_S_AXI_DATA_WIDTH            => C_S_AXI_DATA_WIDTH,
   C_FAMILY                      => "virtex7",
   ----------------              -------------------------
   CE_NUMBERS                    => RDCE_WRCE_CORE
   ------------------            -------------------------
   )
   port map
   (
   -- IP Interconnect (IPIC) port signals ---------
   Bus2IP_Clk                   => bus2ip_clk,
   Bus2IP_Rst                   => reset2ip_reset,
   Bus2IP_RdCE                  => bus2ip_rdce_core,
   Bus2IP_WrCE                  => bus2ip_wrce_core,
   Bus2IP_Addr                  => bus2ip_addr,
   Bus2IP_Data                  => bus2ip_data,       
   -- ip2bus signals ------------------------------
   IP2Bus_Data                  => ip2bus_data,
   IP2Bus_WrAck                 => ip2bus_wrack_core,
   IP2Bus_RdAck                 => ip2bus_rdack_core,
  -- Clock out ports  
   pxl_clk_5x => pxl_clk_5x,
  -- Status and control signals                
   locked => locked,
   -- Clock in ports
   clk_in1 => clk_in1
   );

----------------------------------------------------------
-- SOFT_RESET_I: INSTANTIATE SOFTWARE RESET REGISTER (SRR)
----------------------------------------------------------
SOFT_RESET_I: entity work.system_video_dynclk_0_soft_reset
   generic map
   (
    C_SIPIF_DWIDTH               => C_S_AXI_DATA_WIDTH,
    -- Width of triggered reset in Bus Clocks
    C_RESET_WIDTH                => 16
   )
   port map
   (
    -- Inputs From the AXI Slave Single Bus
    Bus2IP_Reset                 => bus2ip_reset_active_high,  -- in
    Bus2IP_Clk                   => bus2ip_clk,                -- in
    Bus2IP_WrCE                  => bus2ip_wrce_int(SWRESET),  -- in
    Bus2IP_Data                  => bus2ip_data,         -- in
    Bus2IP_BE                    => bus2ip_be,           -- in
    -- Final Device Reset Output
    Reset2IP_Reset               => reset2ip_reset,      -- out
    -- Status Reply Outputs to the Bus
    Reset2Bus_WrAck              => rst_ip2bus_wrack,    -- out
    Reset2Bus_Error              => rst_ip2bus_error,    -- out
    Reset2Bus_ToutSup            => open                 -- out
   );


  ip2bus_wrack_int1  <= ip2bus_wrack_core or 
                   rst_ip2bus_wrack    or
		   dummy_local_reg_wrack;

  ip2bus_rdack_int1  <= ip2bus_rdack_core or 
                   rst_ip2bus_rdack    or
		   dummy_local_reg_rdack;

  ip2bus_error_int1  <= rst_ip2bus_error    or 
                   partial_reg_access_error;


process (Bus2IP_Clk)
begin
    if (Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if (reset2ip_reset = '1') then
           ip2bus_wrack <= '0';
           ip2bus_rdack <= '0';
           ip2bus_error <= '0';
        else
           ip2bus_wrack <= ip2bus_wrack_int1;
           ip2bus_rdack <= ip2bus_rdack_int1;
           ip2bus_error <= ip2bus_error_int1;
        end if;   
    end if;
end process;


---------------------------------

-------------------------------------------------------------------------------

------------------------------------------------------------
-- SW_RESET_REG_READ_ACK_GEN_PROCESS:IMPLEMENT READ ACK LOGIC FOR SOFTWARE
--                                   RESET MODULE. This is dummy read as read is
--                                   not allowed on reset core.
------------------------------------------------------------
SW_RESET_REG_READ_ACK_GEN_PROCESS:process(Bus2IP_Clk) is
begin
  if (bus2ip_clk'event and bus2ip_clk = '1') then
    if (reset2ip_reset = RESET_ACTIVE) then
        rst_ip2bus_rdack_d1 <= '0';
        rst_ip2bus_rdack    <= '0';
    else
        rst_ip2bus_rdack_d1 <= bus2ip_rdce_int(SWRESET);
        rst_ip2bus_rdack    <= bus2ip_rdce_int(SWRESET) and
                               (not rst_ip2bus_rdack_d1);
    end if;
  end if;
end process SW_RESET_REG_READ_ACK_GEN_PROCESS;
---------------------------------------------
-------------------------------------------------------------------------------
-- Logic for generation of error signal for partial word access byte enables
and_reduce_be <= and_reduce(bus2ip_be);

partial_reg_access_error <= (not and_reduce_be)  and
                            (ip2bus_rdack or 
			     ip2bus_wrack);
-------------------------------------------------------------------------------

--------------------------------------------------------------
---- SW_RESET_REG_READ_ACK_GEN_PROCESS:Implement read ack logic for dummy register
----                                   holes. This is dummy read as read/write is
----                                   not returning any value. In local registers.
--------------------------------------------------------------
DUMMY_REG_READ_WRITE_ACK_GEN_PROCESS:process(Bus2IP_Clk) is
begin
  if (bus2ip_clk'event and bus2ip_clk = '1') then
    if (reset2ip_reset = RESET_ACTIVE) then
        dummy_local_reg_rdack_d1 <= '0';
        dummy_local_reg_rdack    <= '0';
	dummy_local_reg_wrack_d1 <= '0'; 
	dummy_local_reg_wrack    <= '0'; 
    else
        dummy_local_reg_rdack_d1 <= or_reduce(bus2ip_rdce_int(5 to 7));
        dummy_local_reg_rdack    <= or_reduce(bus2ip_rdce_int(5 to 7)) and
                                   (not dummy_local_reg_rdack_d1);

        dummy_local_reg_wrack_d1 <= or_reduce(bus2ip_wrce_int(5 to 7));
        dummy_local_reg_wrack    <= or_reduce(bus2ip_wrce_int(5 to 7)) and
                                   (not dummy_local_reg_wrack_d1);

    end if;
  end if;
end process DUMMY_REG_READ_WRITE_ACK_GEN_PROCESS;
-----------------------------------------------
end architecture imp;
