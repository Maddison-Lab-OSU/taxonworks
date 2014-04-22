class Container::Jar < Container

  def self.valid_parents
    ['Container::Drawer', 'Container::UnitTray', 'Container::Cabinet', 'Container::Shelf', 'Container::Virtual', 'Container::VialRack', 'Container::Box']
  end

end
