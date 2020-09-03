/**
    @brief Synchronous Huffman encoder module without using pipelining. 
    @par Hufmman Coding despciption:
          The technique works by creating a binary tree of nodes. These can be stored in a regular array, the size of which depends on the number of symbols (n) A node can be either a leaf node or an internal node. 
          Initially, all nodes are leaf nodes, which contain the SYMBOL itself, the WEIGHT (frequency of appearance) of the symbol and optionally, a link to a PARENT node
          node which makes it easy to read the code (in reverse) starting from a leaf node. Internal nodes contain a WEIGHT, links to TWO CHILD NODES and an optional link to a PARENT node. 
          As a common convention, bit '0' represents following the left child and bit '1' represents following the right child. A finished tree has up to N leaf nodes and N-1 internal nodes. A Huffman tree that omits unused symbols produces the most optimal code lengths. \n
          The process begins with the leaf nodes containing the probabilities of the symbol they represent. Then, the process takes the two nodes with smallest probability, and creates a new internal node having these two nodes as children. 
          The weight of the new node is set to the sum of the weight of the children. We then apply the process again, on the new internal node and on the remaining nodes (i.e., we exclude the two leaf nodes), we repeat this process until only one node remains, which is the root of the Huffman tree.
          
     @par Alghoritm construction:
        The simplest construction algorithm uses a priority queue where the node with lowest probability is given highest priority: \n
        1. Create a leaf node for each symbol and add it to the priority queue. \n
        2. While there is more than one node in the queue: \n
            2.1 Remove the two nodes of highest priority (lowest probability) from the queue\n
            2.2 Create a new internal node with these two nodes as children and with probability equal to the sum of the two nodes' probabilities. \n
            2.3 Add the new node to the queue. \n
        3. The remaining node is the root node and the tree is complete. \n
        Since efficient priority queue data structures require O(log n) time per insertion, and a tree with n leaves has 2n-1 nodes, this algorithm operates in O(n log n) time, where n is the number of symbols.
        
     @par Sorted data algorithm:
        If the symbols are sorted by probability, there is a linear-time (O(n)) method to create a Huffman tree using two queues, 
        the first one containing the initial weights (along with pointers to the associated leaves), and combined weights (along with pointers to the trees) being put in the back of the second queue. 
        This assures that the lowest weight is always kept at the front of one of the two queues: \n
            1. Start with as many leaves as there are symbols. \n
            2. Enqueue all leaf nodes into the first queue (by probability in increasing order so that the least likely item is in the head of the queue). \n
            3. While there is more than one node in the queues: \n
                3.1 Dequeue the two nodes with the lowest weight by examining the fronts of both queues. \n
                3.2 Create a new internal node, with the two just-removed nodes as children (either node can be either child) and the sum of their weights as the new weight. \n
                3.3 Enqueue the new node into the rear of the second queue. \n
            4. The remaining node is the root node; the tree has now been generated.
            
      @par Rest information
        In many cases, time complexity is not very important in the choice of algorithm here, since n here is the number of symbols in the alphabet, which is typically a very small number (compared to the length of the message to be encoded. 
        Whereas complexity analysis concerns the behavior when n grows to be very large.
        It is generally beneficial to minimize the variance of codeword length. For example, a communication buffer receiving Huffman-encoded data may need to be larger to deal with especially long symbols if the tree is especially unbalanced. 
        To minimize variance, simply break ties between queues by choosing the item in the first queue. This modification will retain the mathematical optimality of the Huffman coding while both minimizing variance and minimizing the length of the longest character code.
        
      @waring It is RTL code containing algorithm not implementation.
      
      @param clock Clock signal
      @param inputData Data, which will be encoded
      @param dataEnable This bit has to be high for data to be accepted
      
      @return outputData Encoded data and code map
      @return dataRead High when encoded data is ready to send
      @return codeMapReady High when code map is ready to send
        
*/



module HuffmanEncoder
#(
    parameter bitInByte = 7,        // Number of bits in bytes decrement by one - this simplification let miss phrase bIB -1 during array declaration
    parameter charMaxValue = 255,   // Maximum value, which can be written on 8 bits
    parameter dataLength = 100      // Length of data, which will be coded
)
(
    input wire clock,								
	input wire [bitInByte:0]inputData,				
	input wire dataEnable,			
				
	output reg [bitInByte:0]outputData,
	output reg[bitInByte:0]outputProbabilityList,
	output reg dataReady,				
	output reg codeMapReady						
);	

/**
    @enum States
    @brief State of FSM machine
*/						
    enum{
        INIT =  3'b001,
        GET_DATA,
        BUILD_TREE,
        SEND_TREE
    }States;

    reg [bitInByte:0]probabilityList[charMaxValue:0];				
    reg [bitInByte:0]temp2;
    reg [bitInByte:0]symbolsList[charMaxValue:0];		
    reg [bitInByte:0]Sym,temp1;						

    reg [0:2*bitInByte+2]codesList[charMaxValue:0];		
    reg [bitInByte:0]codeLength[charMaxValue:0];		

    reg [bitInByte:0]huffmanList[charMaxValue:0];		//List used to perform the algorithm on
    reg [bitInByte:0]pairList[2*charMaxValue+2:0];	    //The pair list, an abstraction for the tree concept. even - decode 0. odd - decode 1.

    reg [2:0]state = INIT;													
    reg [bitInByte:0]pos,newpos = 0;				    //Variables to hold values of positions in pair table
    integer step = 0;                                   //Number of steps of tree building algorithm

    reg [bitInByte:0]col = 'b0;						   //Column length
    reg [bitInByte:0]Data[dataLength:0];

    //Loop variables
    integer i= 32'h0;	
    integer j= 32'h0;
    integer k= 32'h0;
    							
    //Flag
    reg flag = 0;										
    
    integer pair_count= 0, sym_count = 0;


always @(posedge clock) begin

	case(state)
	
	INIT: begin
	   symbolsList[0] = 'b0;
	   probabilityList[0] = 'b0;
	
	   for(j=0;j<charMaxValue;j=j+1) begin
	       codesList[j] = 'bz;
	       probabilityList[j] = 'b0;
	       symbolsList[j] = 'bz;
	       codeLength[j] = 'b0;
	   end
	
	   state = GET_DATA;
	end
	
	
	GET_DATA: begin
	if(dataEnable) begin
		Data[i] = inputData;
		i=i+1'b1;
		
			for(j=0;j<=charMaxValue; j=j+1) begin
				if(inputData == symbolsList[j]) begin
					probabilityList[j] = probabilityList[j] + 1;
					
					begin:SORT
						for(k=j-1;k>=0;k=k-1) begin
							if(probabilityList[k] <= probabilityList[j]) begin
								temp1 = symbolsList[j];
								temp2 = probabilityList[j];
								symbolsList[j] = symbolsList[k];
								probabilityList[j] = probabilityList[k];
								symbolsList[k] = temp1;
								probabilityList[k] = temp2;
								
								huffmanList[j] = symbolsList[j];
								huffmanList[k] = symbolsList[k];
								
							end
						end
					end		
					flag=1;
				end	
			end		
			
				
			if(!flag) begin
				symbolsList[col] = inputData;
				huffmanList[col] = inputData;
				probabilityList[col] = 'b1;
				col = col+1;
			end		
			
			flag= 0;
			
		if(i == dataLength)	begin	
		state = BUILD_TREE;
		sym_count = col;
		//$display("col:",col);
		//for(i=0;i<col_length;i=i+1)
		//$display(huffmanList[i],"  ", probabilityList[i]);
		col = col -1 ;
		end
	end
	end
	
	
	BUILD_TREE: begin
		codeMapReady = 0;
		dataReady = 0;
		if(col) begin			//One step per cycle
			probabilityList[col-1] = probabilityList[col] + probabilityList[col-1];		//Added probabilities
		
			pairList[step] = huffmanList[col-1];			//Add in pair table
			pairList[step+1] = huffmanList[col];
		
			col = col - 1;		//removing least symbol
			pair_count = pair_count +2;
		
			begin:SORT1
				for(k=col-1;k>=0;k=k-1) begin
					if(probabilityList[k] < probabilityList[j]) begin
						temp1 = huffmanList[j];
						temp2 = probabilityList[j];
						huffmanList[j] = huffmanList[k];
						probabilityList[j] = probabilityList[k];
						huffmanList[k] = temp1;
						probabilityList[k] = temp2;
					end
				end
			end
			step = step + 2;
			
		end			
		else 
			if(col == 0) begin
			state = BUILD_TREE; 
			//for(i=0;i<2*col_length;i=i+1)
			//$display(pairList[i]);
			//$display(sym_count, "  ",pair_count);
			i=0;
			j=0;
			
			Sym = symbolsList[0];
			end
		end
	SEND_TREE: begin
	   dataReady <= 1;
	   for(k=0;k<charMaxValue;k++) begin
            outputData<=huffmanList[k];
	   end
	   for(k=0;k<charMaxValue;k++) begin
	   	outputProbabilityList<=probabilityList[k];
	   end
	   dataReady <= 0;
	end
	endcase
end

endmodule
