library ieee; 
use ieee.std_logic_1164.all; 
use work.functions.all;


entity CARRY_GENERATOR is
  
  generic (  NBIT   :     integer := 32; 
        NBIT_PER_BLOCK   :     integer := 4);
        
  port (A     : in   std_logic_vector(NBIT-1 downto 0);
        B     : in   std_logic_vector(NBIT-1 downto 0);
        Cin   : in   std_logic;
        Co   : out   std_logic_vector(NBIT/NBIT_PER_BLOCK-1 downto 0));    
end entity;


architecture structural of CARRY_GENERATOR is
  
    -- defines the tree levels
  constant nRow : integer := log2(NBIT) + 1;    
  -- defines a matrix of signals
  type array_t is array (nRow-1 downto 0) of std_logic_vector(NBIT-1 downto 0); 
  signal array_P, array_G: array_t;
  
   component PG_network is
	generic (Nbits : integer :=32);
	port (
		A : in std_logic_vector(Nbits-1 downto 0);
		B : in std_logic_vector(Nbits-1 downto 0);
		Cin : in std_logic; 
		P : out std_logic_vector(Nbits-1 downto 0);
		G : out std_logic_vector(Nbits-1 downto 0));
  end component;
  
  component PG is
	port (
		Pik :	in	std_logic;
		Gik :	in	std_logic;
		Pkj :	in	std_logic;
		Gkj :	in	std_logic;
		Pij :	out	std_logic;
		Gij :	out	std_logic);
  end component;
  
  component G is
	port (
		Pik :	in	std_logic;
		Gik :	in	std_logic;
		Gkj :	in	std_logic;
		Gij :	out	std_logic);
  end component; 

  begin
      
      -- declares the pg network and uses the firs row of p and g signals as exit of the pg network
    PG_NET_INST : PG_network   generic map (NBIT)
                  		port map   (A ,B, Cin, array_P(0), array_G(0));

  G0: for l in 1 to nRow-1 generate  
  
    G1: for i in 0 to NBIT-1 generate
      
      -- starts to generate the first part of PG and G blocks 
      G2: if (l <= log2(NBIT_PER_BLOCK)) generate
        
        -- if here is needded a PG or a G block
        G3: if ((i+1)mod(2**l) = 0) generate
        
          -- if it is a G block generates it
          G4: if (i < 2**l) generate
          
            BLOCK_G : G  port map  (    Pik     => array_P(l-1)(i),
                              Gik     => array_G(l-1)(i),
                              Gkj     => array_G(l-1)(i - 2**(l-1)),
                              Gij     => array_G(l)(i)
                            );

          end generate;
          
          -- if it is a PG block generates it
          G5: if (i >= 2**l) generate
          
            BLOCK_PG : PG  port map  (    Pik     => array_P(l-1)(i),
                              Gik     => array_G(l-1)(i),
                              Gkj     => array_G(l-1)(i - (2**(l-1))),
                              Pkj    =>  array_P(l-1)(i - (2**(l-1))),
                              Gij     => array_G(l)(i),
                              Pij     => array_P(l)(i)
                              );
                              end generate;
        end generate;
      end generate;
      
      -- starts to generate the second part of PG and G blocks 
      G6: if (l > log2(NBIT_PER_BLOCK)) generate
      
        G7: if((i mod (2**l))>=2**(l-1) and (i mod (2**l))<2**l) and (((i+1) mod NBIT_PER_BLOCK) =0) generate
        
          -- if it is a G block
          G8: if (i < 2**l) generate
            
            BLOCK_G_1 : G  port map  (    Pik       => array_P(l-1)(i),
                              Gik     => array_G(l-1)(i),
                              Gkj     => array_G(l-1)((i/2**(l-1))*2**(l-1) - 1),
                              Gij     => array_G(l)(i)
                            );
                              
          end generate;
          
          -- if it is a PG block
          G9: if (i>=2**l) generate
            
            BLOCK_PG_1 : PG port map  (    Pik     => array_P(l-1)(i),
                              Gik     => array_G(l-1)(i),
                              Gkj     => array_G(l-1)((i/2**(l-1))*2**(l-1)-1),
                              Pkj    =>  array_P(l-1)((i/2**(l-1))*2**(l-1)-1),
                              Gij     => array_G(l)(i),
                              Pij     => array_P(l)(i)
                            );
                                
          end generate;
        end generate;
        
        -- if the signal has to be brought to the next level, connects the current row with the previous
        G10: if((i mod (2**l))<2**(l-1) and (i mod (2**l))>=0) and (((i+1) mod NBIT_PER_BLOCK) =0) generate
          
          array_P(l)(i) <= array_P(l-1)(i);
          array_G(l)(i) <= array_G(l-1)(i);
        end generate;
      end generate;
      
      -- if it is the last row, connects the G signals to the carries output      
      G11: if (l = nRow-1) generate
        
        G12: if ((i+1) mod NBIT_PER_BLOCK) = 0 generate
        
          Co(i/NBIT_PER_BLOCK) <= array_G(l)(i);
        end generate;
      end generate;
    end generate;
  end generate;
    
end architecture;      