// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MyContract {

    uint[] busStations = [0,1,2,3,4];
    uint[] stationDistance = [0,2,5,11,23];
    uint public finalfare;

    function calculatefare(uint _station1, uint _station2) public {
        require(_station1 != _station2, "Stations are the same");
        require(_station1 <= busStations.length && _station2 <= busStations.length, "Stations are #0 through #4");

        uint distance;

        
        if (_station1 < _station2) {
            for(uint i=_station1; i<_station2; i++) {
                distance += stationDistance[i+1];
            }
        } else if (_station1 > _station2) {
            for(uint i=_station1; i>_station2; i--) {
                distance += stationDistance[i];
            }
        }

        finalfare = distance;

        }
}