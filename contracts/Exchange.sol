pragma solidity 0.8.0;

import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import './ERC20Token.sol';

contract Exchange {
    using SafeMath for uint;

    address public feeAccount;
    uint256 public feePercent;
    address constant ETHER = address(0);
    mapping(address => mapping(address => uint256)) public tokensMapping;
    mapping(uint256 => _Order) public orders;
    mapping(uint256 => bool) public orderCancelled;
    uint256 public orderCount;
    mapping(uint256 => bool) public orderFilled;

    struct _Order {
        uint256 id;
        address user;
        address tokenGet;
        uint256 amountGet;
        address tokenGive;
        uint256 amountGive;
        uint256 timestamp;
    }

    event Deposit(address _from, address _to, uint256 _amount, uint256 _balance);
    event Withdraw(address _from, address _to, uint256 _amount, uint256 _balance);
    event Order (
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );
    event Cancel (
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );
    event Trade(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        address userFill,
        uint256 timestamp
    );

    constructor(address _feeAccount, uint256 _feePercent) public {
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }

    fallback() external {
        revert();
    }

    function depositEther() payable public {
        tokensMapping[ETHER][msg.sender] = tokensMapping[ETHER][msg.sender].add(msg.value);
        emit Deposit(ETHER, msg.sender, msg.value, tokensMapping[ETHER][msg.sender]);
    }

    function withdrawEther(uint256 _amount) payable public {
        require(tokensMapping[ETHER][msg.sender] >= _amount);
        tokensMapping[ETHER][msg.sender] = tokensMapping[ETHER][msg.sender].sub(_amount);
        payable(msg.sender).transfer(_amount);
        emit Withdraw(ETHER, msg.sender, _amount, tokensMapping[ETHER][msg.sender]);
    }

    function depositToken(address _token, uint256 _amount) public {
        require(_token != ETHER);
        require(ERC20Token(_token).transferFrom(msg.sender, address(this), _amount));
        tokensMapping[_token][msg.sender] = tokensMapping[_token][msg.sender].add(_amount);
        emit Deposit(_token, msg.sender, _amount, tokensMapping[_token][msg.sender]);
    }

    function withdrawToken(address _token, uint256 _amount) public {
        require(_token != ETHER);
        require(tokensMapping[_token][msg.sender] >= _amount);
        tokensMapping[_token][msg.sender] = tokensMapping[_token][msg.sender].sub(_amount);
        require(ERC20Token(_token).transfer(msg.sender, _amount));
        emit Withdraw(_token, msg.sender, _amount, tokensMapping[_token][msg.sender]);
    }

    function balanceOf(address _token, address _user) public view returns (uint256){
        return tokensMapping[_token][_user];
    }

    function makeOrder(address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive) public {
        orderCount = orderCount.add(1);
        orders[orderCount] = _Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, block.timestamp);
        emit Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, block.timestamp);
    }

    function cancelOrder(uint256 _id) public {
        _Order storage _order = orders[_id];
        require(address(_order.user) == msg.sender);
        require(_order.id == _id);
        orderCancelled[_id] = true;
        emit Cancel(_order.id, msg.sender, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive, block.timestamp);
    }

    function fillOrder(uint256 _id) public {
    require(_id > 0 && _id <= orderCount);
    require(!orderFilled[_id]);
    require(!orderCancelled[_id]);
    _Order storage _order = orders[_id];
    _trade(_order.id, _order.user, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive);
    orderFilled[_order.id] = true;
  }

  function _trade(uint256 _orderId, address _user, address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive) internal {
    // Fee paid by the user that fills the order, a.k.a. msg.sender.
    uint256 _feeAmount = _amountGet.mul(feePercent).div(100);

    tokensMapping[_tokenGet][msg.sender] = tokensMapping[_tokenGet][msg.sender].sub(_amountGet.add(_feeAmount));
    tokensMapping[_tokenGet][_user] = tokensMapping[_tokenGet][_user].add(_amountGet);
    tokensMapping[_tokenGet][feeAccount] = tokensMapping[_tokenGet][feeAccount].add(_feeAmount);
    tokensMapping[_tokenGive][_user] = tokensMapping[_tokenGive][_user].sub(_amountGive);
    tokensMapping[_tokenGive][msg.sender] = tokensMapping[_tokenGive][msg.sender].add(_amountGive);

    emit Trade(_orderId, _user, _tokenGet, _amountGet, _tokenGive, _amountGive, msg.sender, block.timestamp);
  }
}

