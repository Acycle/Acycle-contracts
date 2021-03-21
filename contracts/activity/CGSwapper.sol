// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import '../Context.sol';
import '../Libraries.sol';

contract CGSwapper is Operator {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    IBEP20 public cashToken;
    IBEP20 public govToken;

    address public cashDestoryAddress = address(0xffffff);

    //circle
    uint256 public startTime = 1614614400;

    //swaper config
    uint256 totalLevel = 100;
    uint256 FBGAmountPerLevel = 10000 * 1e18;
    uint256 totalFBGAmount = totalLevel * FBGAmountPerLevel;
    uint256 initialSwapRate = 1000; //1000/10000
    uint256 increaseSwapRatePerLevel = 1000; //1000/10000

    //status
    uint256 currentSwapRate = initialSwapRate;
    uint256 currentLevel = 1; //start from 1 to 100
    uint256 currentLeftFBGAmountInLevel = FBGAmountPerLevel;
    //sum
    uint256 swapFBGAmount = 0;
    uint256 swapFBCAmount = 0;

    //event
    event SwapSuccessed(
        address indexed user,
        uint256 fbcCount,
        uint256 fbgCount
    );

    constructor(address cashToken_, address govToken_) {
        cashToken = IBEP20(cashToken_);
        govToken = IBEP20(govToken_);
    }

    function paybackMineToken() public onlyOperator {
        govToken.transfer(msg.sender, govToken.balanceOf(address(this)));
    }

    modifier checkStart() {
        require(block.timestamp >= startTime, 'CGSwapper: not start');
        _;
    }

    function swap(uint256 fbcCount) external checkStart {
        require(fbcCount > 0, 'CGSwapper fbc count must > 0');

        uint256 fbgCount;
        uint256 newLevel;
        uint256 newRate;
        uint256 newFBGLeftInLevel;

        (fbgCount, newLevel, newRate, newFBGLeftInLevel) = _caculateSwap(
            fbcCount
        );

        uint256 caculateTotalFBG = swapFBGAmount.add(fbgCount);
        require(caculateTotalFBG <= totalFBGAmount, 'fbg is not enough');

        /////////////////////do swap

        //change status
        currentSwapRate = newRate;
        currentLevel = newLevel;
        currentLeftFBGAmountInLevel = newFBGLeftInLevel;

        swapFBGAmount = swapFBGAmount.add(fbgCount);
        swapFBCAmount = swapFBCAmount.add(fbcCount);

        //transfer
        govToken.safeTransfer(msg.sender, fbgCount);
        cashToken.safeTransferFrom(msg.sender, cashDestoryAddress, fbcCount);

        //event
        emit SwapSuccessed(msg.sender, fbcCount, fbgCount);
    }

    function _caculateSwap(uint256 fbcCount)
        public
        view
        returns (
            uint256 fbgCount,
            uint256 newLevel,
            uint256 newRate,
            uint256 newFBGLeftInLevel
        )
    {
        uint256 destFBGCount = 0;
        uint256 avaliableFBCCount = fbcCount;

        uint256 tmpLevel = currentLevel;
        uint256 tmpRate = currentSwapRate;
        uint256 tmpLeftFBGCountInlevel = currentLeftFBGAmountInLevel;

        while (avaliableFBCCount > 0) {
            uint256 leftAvaliableFBCCountInLevel =
                tmpLeftFBGCountInlevel.mul(tmpRate).div(10000);
            uint256 currentFbgCount = 0;
            //current level engouh
            if (leftAvaliableFBCCountInLevel >= avaliableFBCCount) {
                currentFbgCount = avaliableFBCCount.mul(10000).div(tmpRate);
                avaliableFBCCount = 0;
                tmpLeftFBGCountInlevel = tmpLeftFBGCountInlevel.sub(
                    currentFbgCount
                );
            } else {
                //need upgrade to next level
                currentFbgCount = leftAvaliableFBCCountInLevel.mul(10000).div(
                    tmpRate
                );
                avaliableFBCCount = avaliableFBCCount.sub(
                    leftAvaliableFBCCountInLevel
                );

                //upgrade level
                tmpLevel++;
                tmpRate = tmpRate.add(increaseSwapRatePerLevel);
                tmpLeftFBGCountInlevel = FBGAmountPerLevel;
            }

            destFBGCount = destFBGCount.add(currentFbgCount);
        }

        fbgCount = destFBGCount;
        newLevel = tmpLevel;
        newRate = tmpRate;
        newFBGLeftInLevel = tmpLeftFBGCountInlevel;
    }

    function queryInfo()
        public
        view
        returns (
            uint256 _swappedFBGCount,
            uint256 _avaliableFBGCount,
            uint256 _totalFBGCount,
            uint256 _swappedFBCCount,
            uint256 _swapRate,
            uint256 _currentLevel,
            uint256 _leftCountInLevel
        )
    {
        _swappedFBGCount = swapFBGAmount;
        _avaliableFBGCount = totalFBGAmount.sub(swapFBGAmount);
        _totalFBGCount = totalFBGAmount;
        _swappedFBCCount = swapFBCAmount;
        _swapRate = currentSwapRate;
        _currentLevel = currentLevel;
        _leftCountInLevel = currentLeftFBGAmountInLevel;
    }

    function setTimeCircle(uint256 starttime_) external onlyOperator {
        startTime = starttime_;
    }
}
