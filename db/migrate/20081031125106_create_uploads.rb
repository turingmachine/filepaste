# Copyright (C) 2008 Andreas Zuber
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class CreateUploads < ActiveRecord::Migration
  def self.up
    create_table :uploads do |t|
      t.string :filename
      t.text :description
      t.string :hash_key
      t.string :content_type

      t.timestamps
    end
  end

  def self.down
    drop_table :uploads
  end
end
