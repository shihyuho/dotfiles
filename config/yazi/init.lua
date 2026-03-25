Status:children_add(function(self)
	local hovered = self._current.hovered
	if hovered and hovered.link_to then
		return " -> " .. tostring(hovered.link_to)
	end
	return ""
end, 3300, Status.LEFT)
