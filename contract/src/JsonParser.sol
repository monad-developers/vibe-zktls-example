// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library JsonParser {
    /**
     * @dev Extracts the value of a given key from a JSON string, supports nested keys.
     * @param json The JSON string to parse.
     * @param key The key whose value needs to be extracted.
     * @return The value associated with the given key.
     */
    function extractValue(string memory json, string memory key) internal pure returns (string memory) {
        bytes memory jsonBytes = bytes(json);
        bytes memory keyBytes = bytes(key);

        // Find the starting position of the key
        for (uint256 i = 0; i < jsonBytes.length; i++) {
            if (isMatch(jsonBytes, keyBytes, i)) {
                // Skip over the `":"` character
                uint256 start = i + keyBytes.length + 3;
                uint256 end = start;

                // Search for the closing quote of the value
                while (end < jsonBytes.length && jsonBytes[end] != '"') {
                    end++;
                }

                bytes memory valueBytes = new bytes(end - start);
                for (uint256 j = start; j < end; j++) {
                    valueBytes[j - start] = jsonBytes[j];
                }

                return string(valueBytes);
            }
        }

        return ""; // Return an empty string if the key is not found
    }

    /**
     * @dev Checks if the given key matches the JSON substring at the specified position.
     * @param jsonBytes The JSON string as bytes.
     * @param keyBytes The key as bytes.
     * @param start The starting index to compare.
     * @return True if the key matches, false otherwise.
     */
    function isMatch(bytes memory jsonBytes, bytes memory keyBytes, uint256 start) internal pure returns (bool) {
        if (start + keyBytes.length >= jsonBytes.length) {
            return false;
        }

        for (uint256 i = 0; i < keyBytes.length; i++) {
            if (jsonBytes[start + i] != keyBytes[i]) {
                return false;
            }
        }

        return true;
    }
}