package gr.debug
{
    import gr.utils.JSON;

    public function inspect( o:Object ):String
    {
        return JSON.serialize(o);
    }
}
