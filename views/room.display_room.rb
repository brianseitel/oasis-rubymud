<%= @args[:title].to_s.cyan %>
<%= @args[:exits].to_s.white %>
<%= @args[:description].to_s.yellow %>
<% if (@args[:mobs].length) %><%= @args[:mobs].to_s.light_white -%> <% end %>
<% if (@args[:people].length) %><%= @args[:people].to_s.cyan -%><% end %>