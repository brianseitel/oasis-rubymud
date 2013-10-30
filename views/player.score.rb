<%= @args[:name] %><%= @args[:spaces1] %><%= @args[:level] %><%= @args[:spaces1] %><%= @args[:tnl] %>
<%= @args[:dashes] -%>
<% @args[:stats].each do |stat, value| %>
<%= stat %><%= @args[:splits][stat] %><%= value -%>
<% end %>
<%= @args[:dashes] %>
