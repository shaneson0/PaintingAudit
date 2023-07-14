//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./NFT.sol";
import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract MainPaint{
    //main function: paint(); transfer_painter(); swap_color(); votetomintfinal(); dividefinalart();
    //dynamic canvas change uri:  finaluri_pre(); changeuri_final()

    //color mapping
    /*R1 = #d24430;    100% pure blue
        R2 = #da6959   80% pure blue
        R3 = "#e58c84  60% pure blue
        R4 = #ebb4ad   40% pure blue
        R5 = #f5d9d6   20% pure blue
        B1 = #4574e6   100% pure red
        B2 = #688fea   80% pure red
        B3 = #8da9f2   60% pure red
        B4 = #b3c3f4   40% pure red
        B5 = #d4ddfa   20% pure red
    */

    string private url_string;
    string private coordinate;
    string private color_map;
    string private coordinate_map;
    uint256 public  recentdividentime;

    string public final_uri;
    address public initial_painter;
    
    uint256 private tokenId;
    uint256 public vote_num =0;
    uint256 public price;
    uint256 public startdividentime =0;    

    address public market;
    
    bool public final_mint = false;
    bool public dividen = false;
    bool public vote = true;  

    mapping (address => uint256 ) paint_right; //2 = you should paint  3 = you should transfer
    mapping (address =>uint256) recent_redcolor;
    mapping (address =>uint256) recent_bluecolor;
    mapping (address => uint256) paint_account; 

    mapping (uint256 => string) nftcolor; //tokenid => color
    mapping (uint256 => string) nftcoordinate;//tokenid => coordinate
    mapping (string => uint256) NFT_position;//coordinate => tokeni d

    mapping (uint256 => mapping(uint256 => uint256)) coordinatexy; //if coordinate is painted => 2
    mapping (uint256 => mapping(uint256 => string)) visual_map; //canvas data
    mapping (address => bool) vote_statu;
    mapping (uint256 => bool) vote_done;
    mapping (uint256 => bool) dividen_done;//dividen done
    mapping (address => bool) painter_ornot;
    mapping (uint256 => cord_list) tokenid_coord;
    struct cord_list{
        uint32 cord_x;
        uint32 cord_y;
    }
    
    uint256[] private own_nft;
    uint256[] public dividen_record; //which one has been dividen
    string[] public position_done;//the painted coordinate
    address[] public painter_record;
    uint256[] public serve_check; //tokenid

    event painter_condition(address painter_address, uint256 bluecolornow, uint256 redcolornow, uint256 paint_right_);
    event newpainter_condition(address newpainter_address, uint256 newpainter_bluecolornow, uint256 newpainter_redcolornow, uint256 newpaint_right_);
    event record_event(string state1);
    event record_swap(uint256 tokenid_1, uint256 tokenid_2);
    event record_address(address contract_);
    event vote_1(string situation1);
    event print(string mes);

    NFT public nft = new NFT(); //subcontract nft

    constructor() {
        initial_painter = msg.sender;//artist
        
    }
    function subcontract_address()public view returns(address){ 
        return (address(nft));
    }

    // artist work
    modifier initial_work{
        require(initial_painter == msg.sender, "you don't have the power");
        _;
    }
    function marketaddress(address market_)public initial_work{
        market = market_;
        emit record_address(market);
    }

    function approve_market() public {
        require(msg.sender == nft.ownerOf(1));
        nft.approveNFT(market,1);
        emit record_event("approve");
    }

    function initial_paint(address startpaint, uint256 color_state) public initial_work{ //give right to two participants 1blue 2red
        paint_right[startpaint] = 2; //2 = paint right
        if(color_state == 1){
            recent_bluecolor[startpaint] = 1;
        }
        else if(color_state == 2){
            recent_redcolor[startpaint] = 1;
        }
        emit painter_condition(startpaint, recent_bluecolor[startpaint], recent_redcolor[startpaint], paint_right[startpaint]);

    }

    //start participants work

    modifier can_paint {
        require( paint_right[msg.sender] == 2,"you should transfer firstly");
        _;
    }
    function paint(uint32 x, uint32 y) public can_paint{//x and y is the coordinate, your right should be 2
        require ( coordinatexy[x][y] != 2, "this position has been painted"); //coordinate can't be same
        require(x <= 30 && y <= 16, "Please input the correct coordinate");   //the range of canvas
        
        coordinate = string(abi.encodePacked("(",Strings.toString(x),".",Strings.toString(y),")"));
        coordinatexy[x][y] = 2;
        
        //generate ipfs uri based color and coordinate
        if (recent_bluecolor[msg.sender] != 0){
            url_string = string(abi.encodePacked("ipfs://QmUUYrSLThxLuUqqdpwT4ozeGKw8JsRNiGzQTjSB1xWFFR/", Strings.toString(x),"_", Strings.toString(y), "_B", Strings.toString(recent_bluecolor[msg.sender]),".json"));
            color_map = string(abi.encodePacked("_B", Strings.toString(recent_bluecolor[msg.sender]),".json")); 
            if (recent_bluecolor[msg.sender] == 1){
                visual_map[x][y] = "B1";
            } else if(recent_bluecolor[msg.sender] == 2){
                visual_map[x][y] = "B2";
            } else if(recent_bluecolor[msg.sender] == 3){
                visual_map[x][y] = "B3";
            }else if(recent_bluecolor[msg.sender] == 4){
                visual_map[x][y] = "B4";
            }else if(recent_bluecolor[msg.sender] == 5){
                visual_map[x][y] = "B5";
            }
                
        }else if(recent_redcolor[msg.sender] != 0){
            url_string = string(abi.encodePacked("ipfs://QmUUYrSLThxLuUqqdpwT4ozeGKw8JsRNiGzQTjSB1xWFFR/", Strings.toString(x),"_", Strings.toString(y), "_R", Strings.toString(recent_redcolor[msg.sender]),".json"));
            color_map = string(abi.encodePacked("_R", Strings.toString(recent_redcolor[msg.sender]),".json"));
            if (recent_redcolor[msg.sender] == 1){
                visual_map[x][y] = "R1";
            } else if(recent_redcolor[msg.sender] == 2){
                visual_map[x][y] = "R2";
            } else if(recent_redcolor[msg.sender] == 3){
                visual_map[x][y] = "R3";
            }else if(recent_redcolor[msg.sender] == 4){
                visual_map[x][y] = "R4";
            }else if(recent_redcolor[msg.sender] == 5){
                visual_map[x][y] = "R5";
            }
        }
        coordinate_map = string(abi.encodePacked(Strings.toString(x),"_", Strings.toString(y))); 
        tokenId = nft.safeMint(msg.sender, url_string) -1;
        
        //record data
        nftcoordinate[tokenId] = coordinate_map;
        nftcolor[tokenId] = color_map;
        tokenid_coord[tokenId].cord_x = x;
        tokenid_coord[tokenId].cord_y = y;
        position_done.push(coordinate);
        NFT_position[coordinate] = tokenId;
        serve_check.push(tokenId);
        paint_account[msg.sender] = paint_account[msg.sender] + 1;

        if (painter_ornot[msg.sender] == false){
            painter_record.push(msg.sender);
            painter_ornot[msg.sender] = true;
        }

        if (paint_account[msg.sender] >= 2){
            paint_right[msg.sender] = 3;
            paint_account[msg.sender] = 0;
        }

        emit painter_condition(msg.sender, recent_bluecolor[msg.sender], recent_redcolor[msg.sender], paint_right[msg.sender]);
        
    }


    modifier can_transfer {
        require( paint_right[msg.sender] == 3,"you should paint firstly"); 
        _;
    }
    
    function transfer_painter(address newpainter) public can_transfer { //newpainter should never have been transferred
        require (paint_right[newpainter] == 0, "this count already join painting" ); 
        paint_right[newpainter] = 2;//give newpainter the right of paint
        //give your color to newpainter and you will get new color
        if (recent_bluecolor[msg.sender] != 0){
            recent_bluecolor[newpainter] = recent_bluecolor[msg.sender];
            if(recent_bluecolor[msg.sender] < 5){
                recent_bluecolor[msg.sender] = recent_bluecolor[msg.sender] +1;
            }
        }else if(recent_redcolor[msg.sender] != 0){
            recent_redcolor[newpainter] = recent_redcolor[msg.sender];
            if(recent_redcolor[msg.sender]< 5){
                recent_redcolor[msg.sender] = recent_redcolor[msg.sender] +1;
            }
        }  
        paint_right[msg.sender] = 2; //give you the right of paint
        emit painter_condition(msg.sender, recent_bluecolor[msg.sender], recent_redcolor[msg.sender], paint_right[msg.sender]);
        emit newpainter_condition(newpainter, recent_bluecolor[newpainter], recent_redcolor[newpainter], paint_right[newpainter]);
    }
    
    function swap_color(uint256 tokenId_first, uint256 tokenId_second) public {//the tokenids of your two NFT
        
        require(nft.ownerOf(tokenId_first) == msg.sender && nft.ownerOf(tokenId_second) == msg.sender, "you don't have this NFT");
        //exchange color
        string memory tokenId2_newmap = nftcolor[tokenId_first];
        nftcolor[tokenId_first] = nftcolor[tokenId_second];
        nftcolor[tokenId_second] = tokenId2_newmap;
        //new uri
        string memory url1 = string(abi.encodePacked("ipfs://QmUUYrSLThxLuUqqdpwT4ozeGKw8JsRNiGzQTjSB1xWFFR/", nftcoordinate[tokenId_first], nftcolor[tokenId_first]));
        string memory url2 = string(abi.encodePacked("ipfs://QmUUYrSLThxLuUqqdpwT4ozeGKw8JsRNiGzQTjSB1xWFFR/", nftcoordinate[tokenId_second], nftcolor[tokenId_second]));
        //mint same tokenid NFT
        nft.exchangeMint(tokenId_first,  url1);
        nft.exchangeMint(tokenId_second, url2);
        
        //record data 
        uint32 x1 = tokenid_coord[tokenId_first].cord_x;
        uint32 y1 = tokenid_coord[tokenId_first].cord_y;
        uint32 x2 = tokenid_coord[tokenId_second].cord_x;
        uint32 y2 = tokenid_coord[tokenId_second].cord_y;
        string memory exchange_map = visual_map[x2][y2]; 
        visual_map[x2][y2] = visual_map[x1][y1];
        visual_map[x1][y1] = exchange_map;

        serve_check.push(tokenId_first);
        serve_check.push(tokenId_second);        

        emit record_swap(tokenId_first, tokenId_second);
    }

    modifier owner_nft {
        require(position_done.length> 320,"you still should wait until 300 pixels have been painted");// 2/3 num of pixels 1200-1 
        require(vote == true, "this step has already stopped"); 
        _;
    }

    function votetomintfinal() public owner_nft { //Vote to determine whether to mint the final artwork
        bool nftowner = false;
        uint256 own_num = 0; // how many nft you have
        for (uint256 i=0; i< position_done.length; i++){    
            if (nft.ownerOf(i+2) == msg.sender && vote_done[i+2] == false){
                own_num = own_num+1;
                vote_done[i+2] = true;
            }          
        }
        if (own_num > 0){
            nftowner = true;
        }
        require(nftowner == true,"you are not the co-painter or your nfts have already voted");  

        vote_num = vote_num + own_num;

        if (vote_num*2 >= position_done.length){
            final_mint = true;
            vote_num = 0;
            vote = false;
            emit vote_1("The final mint start");
        } else if (vote_num*2 < position_done.length){
            emit vote_1("Waiting for other holders to vote");
        }      
    } 
    
 

 //改成visualization
    function finaluri_pre() public returns (string memory) {//generate canvas string
        final_uri = visualization();
        emit print(final_uri);  
    }

    function  changeuri_final() public {
        require(nft.ownerOf(1) == msg.sender,"not owner");
        nft.uploadfinaluri(final_uri);
        nft.setfinalTokenURI();
        emit record_event("change uri success");
    }

    function mint_uri_final()public {
        require(final_mint == true);
        require(msg.sender == initial_painter);
        nft.uploadfinaluri(final_uri);
        nft.safefinalMint(msg.sender);
        dividen = true;
        emit record_event("mint the canvas");
    }

    modifier dividen_owner {
        require(dividen == true, "the nft has not minted");        
        _;
    }

    function dividefinalart() public dividen_owner payable {
        bool nftowner = false;
        uint256 own_num = 0; // how many nft you have
        for (uint256 i=0; i< position_done.length; i++){
            
            if (nft.ownerOf(i+2) == msg.sender){
                own_num = own_num+1;
                own_nft.push(i+2);
            }            
        }
        if (own_num > 0){
            nftowner = true;
        }
        require(nftowner == true,"you are not the co-painter");

        uint256 dividen_num = 0;  // how many nft you can divid
        recentdividentime = block.timestamp;
        if (startdividentime == 0 ){
            startdividentime = recentdividentime;
        } else if (recentdividentime - startdividentime >= 60*60*24*30){ //60*60*24*30 one month //reset
            for (uint256 i=0; i < dividen_record.length; i++){
                dividen_done[dividen_record[i]] = false;
            }
            startdividentime = recentdividentime;
            delete dividen_record; 
        }
       for (uint256 i=0; i< own_nft.length; i++){
            if (dividen_done[own_nft[i]] == false){
                dividen_num = dividen_num+1;
                dividen_done[own_nft[i]] = true; 
                dividen_record.push(own_nft[i]);
            }      
        }
        require (dividen_num > 0, "your nft have been dividen");
        price = address(this).balance;
        uint256 recieve_price = dividen_num * price / 480;  
        payable(msg.sender).transfer(recieve_price);
        delete own_nft;
        emit record_event("divide success");
    }


    function visualization() public view returns(string memory){//canvas on chain
        string memory sum_visual;

        for (uint32 i=16; i>=1; i--) {
            for (uint32 z=1; z< 31; z++){               
                if(coordinatexy[z][i] == 2){
                    sum_visual = string(abi.encodePacked(sum_visual, visual_map[z][i]));
                }else{
                    sum_visual = string(abi.encodePacked(sum_visual, "|..| "));
                }  

                if (z == 30){
                    sum_visual = string(abi.encodePacked(sum_visual, ">>"));
                }
            }
        }
        return sum_visual;
    }

    function checkCoordinatexy(uint256 x, uint256 y) public view returns(uint256){    //if coordinate is painted => 2
        return coordinatexy[x][y];
    }

    function checkvoteresult() public view returns(bool){ //if true means can mint final art work
        return final_mint;
    }

    function checknftdividen(uint256 tokenId) public view returns(bool){//check the nft was dividen or not
        return dividen_done[tokenId];
    }
    function checkvote(uint256 tokenId) public view returns(bool){ //2 means has voted
        return vote_done[tokenId]; 
    }

    function checkmarketopen() public view returns(bool){ //if true market open
        return dividen; 
    }

    function checkpositiondown() public view returns(uint256){// how many pixels have been painted
        return position_done.length;
    }
    function right( address checkright ) public view returns(uint256){// the address can paint(2) or transfer(3) 
        return paint_right[checkright];  
    }

    function redcolor( address checkpainter) public view returns(uint256){
        return recent_redcolor[checkpainter];   
    }
    function bluecolor( address checkpainter) public view returns(uint256){
        return recent_bluecolor[checkpainter];    
    }
    
    function checkownerfirst() public view returns(uint256){
        return tokenId;      
    }    

    function checkowner(uint256 tokenId) public view returns(address){ //the nft owner
        return nft.ownerOf(tokenId);
    }

    function getcolor(uint256 tokenId) public view returns(string memory){//the nft color
        return nftcolor[tokenId];
    }

    function getcoordinate(uint256 tokenId) public view returns(string memory){//the nft position
        return nftcoordinate[tokenId];
    }

    function serve_compare() public view returns(uint256){
        return serve_check.length;
    }

    function serve_update(uint256 array) public view returns(uint256){
        return serve_check[array];
    }
        
    function tokenURI(uint256 tokenId) public view returns(string memory){
        return nft.tokenURI(tokenId);
    }
    
    function checktokenId(string memory coordinate) public view returns(uint256){//which nft on this posiiton
        return NFT_position[coordinate];
    }

    function checklength() public view returns(uint256){
        return position_done.length;
    }

    function checkcontractbalance() public view returns(string memory){       
        uint256 balance_contract = address(this).balance;
        return string(abi.encodePacked(Strings.toString(balance_contract),"Wei"));
    }

    function checkdividen() public view returns(uint256){
        return position_done.length;     
    }

    function checkmarketcontract() public view returns(address){
        return market;
    }

    function checkpainter_num() public view returns (uint256){
        return painter_record.length;
    }

    function checkvotestate() public view returns(bool){
        return vote;
    }

    function dividentime_start() public view returns(uint256){
        return startdividentime;
    }

    function dividentime_recent() public view returns(uint256){
        return block.timestamp;
    }
 
    fallback() external payable {}
    
    receive() external payable {}


}


