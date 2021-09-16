// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PaymentSplitter is Ownable{

    using SafeMath for uint256;
    
    event PayeeAdded(address account);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    address[] private _payees;
   
    // This function distributes all the available ethers
    function distribute() public payable onlyOwner{
        
        uint256 totalamount =  address(this).balance;
        address owner = owner();
        
        if(_payees.length == 0){
        // pay owner everthing
        bool sentJustOwner = payable(owner).send(totalamount);
        require(sentJustOwner, "Failed to send Ether");
        emit PaymentReleased(owner, totalamount);
        }
        else {
        // pay owner's 80% cut
        uint256 ownersCut =  totalamount.mul(80).div(100);     
        bool sentOwner = payable(owner).send(ownersCut);
        require(sentOwner, "Failed to send Ether");
        emit PaymentReleased(owner, ownersCut);
        
        // pay everyone remaining 20%
        uint remaining = totalamount.sub(ownersCut);
        uint remainingForEach = remaining.div(_payees.length);
              
        for (uint256 i = 0; i < _payees.length; i++) {
            bool sentPayee = payable(_payees[i]).send(remainingForEach);
            require(sentPayee, "Failed to send Ether");
            emit PaymentReleased(_payees[i], remainingForEach);
          }
        }
    }

    // for testing
    function totalBalanceAvailable() public view returns(uint256) {
        return  address(this).balance;
    }
  

    function allPayees() public view returns (address[] memory){
        return _payees;
    }

    //public for testing
    function _addPayee(address account) public {
        _payees.push(account);
        emit PayeeAdded(account);
    }
    
}


