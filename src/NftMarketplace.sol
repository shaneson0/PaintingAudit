//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";


// For a full decentralized nft marketplace

error PriceNotMet();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();


// Error thrown for isNotOwner modifier
// error IsNotOwner()

contract NftMarketplace is ReentrancyGuard {
    bool dividen = false;
    bool public state_sale; //false is off the shelf and true is on sale
    uint256 public recent_price;
    mapping (address => uint256) public earn; //seller => benefit
    address public recent_seller;
    address public nftAddress;
    address public mainAddress;
    address public creator;
    uint256 public num_sell = 0;//number of purchase
    event history (uint256 time, uint256 price, address from, address to);
    event record_event(string state1);
    event record_num(uint256 num_);
    event record_address(address address_);
    mapping( uint256 => sell_history) public history_list;
    struct sell_history{
        address from;
        address to;
        uint256 time;
        uint256 price;
    }


    constructor () {
        creator = msg.sender;
    }
    function set_nftAddress (address nftcontract_Address) public{
        require (msg.sender == creator, "no right");
        nftAddress = nftcontract_Address;
        emit record_address(nftAddress);
    }

    function set_mainaddress(address copaint_Address) public {
        require (msg.sender == creator, "no right");
        mainAddress = copaint_Address;
        emit record_address(mainAddress);
    }


    modifier isOwner(
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(1);
        if (spender != owner) {
            revert NotOwner();
        }
        _;
    }

    function upload_price(//sell the final artwork
        uint256 price  
    )
        public
        isOwner( msg.sender)
    {
        if (price <= 0) {
            revert PriceMustBeAboveZero();
        }
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(1) != address(this)) {
            revert NotApprovedForMarketplace();
        }
        recent_price = price; //record price
        recent_seller = msg.sender;
        state_sale = true;
        emit record_num(recent_price);

    }


    function cancelListing() //stop selling the final artwork
        public
        isOwner(msg.sender)
    {
        require (state_sale == true, "didn't sale");
        recent_price = 0;
        recent_seller = address(0);
        state_sale = false;
        emit record_event("cancel list");
    }


    function buyItem() //buy the final artwork
        public
        payable
        nonReentrant
    {
        require(state_sale == true, "didn't sale");
        require(msg.value == recent_price);
        
        if (msg.value < recent_price ) {
            revert PriceNotMet();
        }
        IERC721(nftAddress).safeTransferFrom(recent_seller, msg.sender, 1);
        
        num_sell = num_sell+1;
        if (earn[recent_seller] >0){
            earn[recent_seller] = earn[recent_seller] + msg.value;
        } else if (earn[recent_seller] == 0){
            earn[recent_seller] = msg.value;
        }
        
        history_list[num_sell] = sell_history({
            from: recent_seller,
            to: msg.sender,
            time: block.timestamp,
            price: recent_price
        });



        recent_price = 0;
        state_sale = false;
        emit history(block.timestamp, msg.value, recent_seller, msg.sender);
        recent_seller = address(0);
 
    }


    function benefit() public payable { //seller get the benefit
        uint256 proceeds = earn[msg.sender];
        require (proceeds > 0);
        if (num_sell == 1){
            payable(mainAddress).transfer(proceeds); //first time dividen
            dividen = true;
            emit record_num(proceeds);
        } else if(num_sell !=1){
            payable(msg.sender).transfer(proceeds*9/10); //seller
            payable(mainAddress).transfer(proceeds-proceeds*9/10); //dividen
            emit record_num(proceeds-proceeds*9/10);
        }
        earn[msg.sender] = 0;
        

    }

    function checkdividen() public view returns(bool){
        return dividen;
    }

    function checkstate() public view returns(bool){
        return state_sale;
    }  

    function checkrecentseller() public view returns(address){
        return recent_seller;
    }

    function checkpreseller() public view returns(uint256){
        return earn[msg.sender];
    }

    function checkprice() public view returns(uint256){
        return recent_price;
    }

    function check_approve_market() public view returns(bool){
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(1) != address(this)) {
            return false;
        } else if(nft.getApproved(1) == address(this)){
            return true;
        }
    }
    function checknum_sell() public view returns(uint256){
        return num_sell;
    }
    function check_selllist(uint256 num) public view returns(sell_history memory ){ // range of num = (1 _ numsell) 
        return history_list[num];

    }

}

