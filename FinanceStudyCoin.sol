pragma solidity 0.5.4;


library SafeMath {
    function add(uint a, uint b) internal pure returns(uint) {
        uint c = a + b;
        require(c >= a);

        return c;
    }

    function sub(uint a, uint b) internal pure returns(uint) {
        require(b <= a);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns(uint) {
        if(a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint a, uint b) internal pure returns(uint) {
        uint c = a / b;

        return c;
    }
}

contract Ownable {
    address payable public owner;
    
    event OwnershipTransferred(address newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable newOwner) onlyOwner public  {
        require(newOwner != address(0));

        owner = newOwner;
        emit OwnershipTransferred(owner);
    }
}

contract ERC20 {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract StudyCoin is Ownable, ERC20 {
    using SafeMath for uint;
    
    
    string public symbol = "FSC";
    string public  name = "Finance Study Coin";
    uint8 public decimals = 18;
    uint public amount_eth = 0;
    uint public token_price = 4;
    uint public _totalSupply = 100 * 10 ** uint(decimals);
    uint internal _eth;
    uint public sellPrice = token_price + token_price /2;

    mapping (address => uint) internal _balances;
    mapping (address => mapping (address => uint)) internal _allowed;
    mapping (address => uint) internal _etherBalances;
    event TokenSold(address seller, uint tokens, uint inWei);
    
    constructor() public {
        _balances[owner] = _totalSupply * 5/100;
        _balances[address(this)] = _totalSupply * 95/100;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) view public returns (uint balance) {
        return _balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool) {
        require(_balances[msg.sender] >= tokens);
        require(to != address(0));

        _balances[msg.sender] = _balances[msg.sender].sub(tokens);
        _balances[to] = _balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    function approve(address spender, uint tokens) public returns (bool) {
        // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve (see NOTE)
        if ((tokens != 0) && (_allowed[msg.sender][spender] != 0)) {
            revert();
        }

        _allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender) view public returns (uint remaining) {
        return _allowed[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool) {
        require(_balances[from] >= tokens);
        require(to != address(0));

        uint _allowance = _allowed[from][msg.sender];

        _balances[from] = _balances[from].sub(tokens);
        _balances[to] = _balances[to].add(tokens);
        _allowed[from][msg.sender] = _allowance.sub(tokens);

        emit Transfer(from, to, tokens);

        return true;
    }
    
     function buy () public payable {
        require(msg.value > 0);
        require(_balances[address(this)] > msg.value * token_price);
        
        amount_eth += msg.value;
        uint tokens = msg.value * token_price;
        _balances[msg.sender] += tokens;
        
        
        emit Transfer(address(this), msg.sender, tokens);
    }
    
    function sell(uint tokens) public {
        require(_balances[msg.sender] >= tokens);
        
        burn(tokens);

        uint weiAmount = tokens.mul(sellPrice);
        _etherBalances[msg.sender] = _etherBalances[msg.sender].add(weiAmount);

        emit TokenSold(msg.sender, tokens, weiAmount);
    }

    function burn(uint tokens) private {
        _balances[msg.sender] = _balances[msg.sender].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
    }
    
     function withdraw(uint myAmount) onlyOwner public {
		require(address(this).balance >= myAmount, "Insufficient funds.");
		
		owner.transfer(myAmount);
	}
   
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20(tokenAddress).transfer(owner, tokens);
    }
}


