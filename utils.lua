---@param word string
---@return string
function CapitalizeFirstLetter(word)
	return string.upper(string.sub(word, 1, 1))
		.. string.sub(word, 2, string.len(word))
end
