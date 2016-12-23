type RegistryItem: void {
  .name: string
  .city: string
  .location: string
}


type GetRegistryItemsResponse: void {
  .item*: RegistryItem
}

type RemoveRegistryItemRequest: void {
  .name: string
}

interface FrontendInterface {
  RequestResponse:
    addRegistryItem( RegistryItem )( void )
      throws NameAlreadyExists,
    removeRegistryItem( RemoveRegistryItemRequest )( void ),
    getRegistryItems( void )( GetRegistryItemsResponse )
}
