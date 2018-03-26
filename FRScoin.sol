pragma solidity ^0.4.18;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}
contract BurnableToken is BasicToken {
  event Burn(address indexed burner, uint256 value);
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value);
  }
}

contract FRScoin is BurnableToken {
  string public constant name = "FRScoin"; // solium-disable-line uppercase
  string public constant symbol = "FRS"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase

  uint256 public constant INITIAL_SUPPLY = 33000000 * (10 ** uint256(decimals));

  enum States {
    Sale,
    Stop
  }
  States public state;        
  address public initialHolder;
  uint256 public discount = 35;
  uint256 public softcap = 1000000 * (10 ** uint256(decimals));

  function FRScoin() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    initialHolder = msg.sender;
    state = States.Sale;
  }

  modifier requireState(States _requiredState) {
    require(state == _requiredState);
    _;
  }
  modifier onlyOwner() {
    require(msg.sender == initialHolder);
    _;
  }
  function requestPayout(uint256 _amount)
  onlyOwner
  public
  {
    msg.sender.transfer(_amount);
  }
  modifier minAmount(uint256 amount) {
    require(amount >= 800000000000000);
    _;
  }
  function changePercent(uint256 _new_percent)
  onlyOwner
  public 
  {
  	discount = _new_percent;
  }
  function changeState(States _newState)
  onlyOwner
  public
  {
    state = _newState;
  }
  
  function() payable
  requireState(States.Sale)
  minAmount(msg.value)
  public
  {
    uint256 _coinIncrease = msg.value * 1250;
    uint256 _coinBonus = _coinIncrease * discount / 100;
    uint256 _total = _coinIncrease + _coinBonus;
    balances[initialHolder] = balances[initialHolder].sub(_total);
    balances[msg.sender] = balances[msg.sender].add(_total);
    Transfer(initialHolder, msg.sender, _total);
  }
}
