import { KiemTraGiuaKyTemplatePage } from './app.po';

describe('KiemTraGiuaKy App', function () {
    let page: KiemTraGiuaKyTemplatePage;

    beforeEach(() => {
        page = new KiemTraGiuaKyTemplatePage();
    });

    it('should display message saying app works', () => {
        page.navigateTo();
        expect(page.getParagraphText()).toEqual('app works!');
    });
});
